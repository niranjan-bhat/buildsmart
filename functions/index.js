const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const { logger } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");
const { getMessaging } = require("firebase-admin/messaging");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const { v4: uuidv4 } = require("uuid");

initializeApp();

const db = getFirestore();
const storage = getStorage();
const messaging = getMessaging();

const BUCKET_NAME = "buildsmart-35f5b.firebasestorage.app";
const geminiApiKey = defineSecret("GEMINI_API_KEY");

const CONSTRUCTION_STAGES_PROMPT = `
You are an expert construction site inspector AI with deep knowledge of building construction phases and defects.

The 11 construction stages you must identify are:
1. Site Preparation - Cleared land, excavation equipment, soil grading, boundary markings, removal of vegetation and debris, setting out pegs and batter boards
2. Foundation - Excavated trenches, concrete footings, reinforcement bars (rebar) in trenches, formwork, poured concrete at ground level or below, strip foundations or raft slabs
3. Plinth - Concrete or masonry walls just above ground level, damp proof course (DPC) layer, plinth beam visible, backfilling around foundation walls
4. Superstructure / Framing - Vertical columns rising from plinth, horizontal beams, concrete frame or steel structure, structural skeleton without walls, formwork and scaffolding
5. Brickwork / Masonry - Brick or concrete block walls being laid between columns, mortar joints visible, partially completed wall panels, window and door openings formed, lintel placement
6. Roofing - Roof slab formwork or timber truss installation, roof deck, waterproofing membrane, roof tiles or metal sheets being fixed, parapet walls, gutters and drainage
7. Plumbing Rough-in - PVC or metal pipes running through walls and floors, drainage pipes, soil pipes, water supply lines, pipe sleeves in walls, no fixtures installed yet
8. Electrical Rough-in - Electrical conduits in walls and ceilings, junction boxes, switch boxes embedded in walls, wiring running through conduits, consumer unit position
9. Plastering - Wet or dried plaster on walls and ceilings, smooth or textured surface over brickwork, corner beads, plaster drying marks
10. Flooring - Floor tiles being laid, tile adhesive, screed being applied, tile joints being grouted, floor leveling compound, skirting boards
11. Finishing - Painting, fitted doors and windows, sanitary ware installed, light fittings, switches and sockets fitted, kitchen cabinets, interior decoration, external rendering

RESPONSE FORMAT:
You MUST respond with ONLY valid JSON in the exact schema below. No markdown, no code blocks, no explanation.

If the image is NOT a construction site image, respond with:
{"error":"NON_CONSTRUCTION_IMAGE"}

If it IS a construction image, respond with:
{
  "construction_stage": "<one of the 11 stage names exactly as written above>",
  "stage_confidence": "<HIGH|MEDIUM|LOW>",
  "defects": [
    {
      "title": "<short defect title>",
      "description": "<detailed description of the defect>",
      "confidence": "<HIGH|MEDIUM|LOW>",
      "rectification_steps": ["Step 1", "Step 2", "Step 3"]
    }
  ],
  "best_practices": ["<tip 1>", "<tip 2>", "<tip 3>"],
  "overall_assessment": "<PASS|FAIL|WARNING>",
  "analysis_id": "<unique identifier>"
}

RULES:
- overall_assessment is PASS if no significant defects, FAIL if critical structural/safety defects, WARNING if minor issues
- List up to 5 most significant defects
- Provide 3-5 best practices relevant to the identified stage
- rectification_steps should be practical and actionable (2-5 steps per defect)
- Be precise and use construction industry terminology
- stage_confidence: HIGH if very clear, MEDIUM if somewhat ambiguous, LOW if multiple stages possible

Now respond with ONLY the JSON.
`;

exports.analyzeConstructionImage = onDocumentCreated(
  {
    document: "users/{userId}/projects/{projectId}/images/{imageId}",
    timeoutSeconds: 120,
    memory: "1GiB",
    secrets: [geminiApiKey],
  },
  async (event) => {
    const { userId, projectId, imageId } = event.params;
    const snap = event.data;
    const imageData = snap.data();

    logger.info("Starting analysis", { userId, projectId, imageId });

    if (!imageData?.storagePath) {
      await snap.ref.update({
        status: "error",
        errorMessage: "Missing storagePath",
        analyzedAt: FieldValue.serverTimestamp(),
      });
      return null;
    }

    try {
      await snap.ref.update({
        status: "processing",
        analyzedAt: FieldValue.serverTimestamp(),
      });

      const bucket = storage.bucket(BUCKET_NAME);
      const file = bucket.file(imageData.storagePath);
      const [exists] = await file.exists();

      if (!exists) {
        throw new Error(`File not found in storage: ${imageData.storagePath}`);
      }

      const [fileBuffer] = await file.download();
      const mimeType = getMimeType(imageData.storagePath);

      const apiKey = geminiApiKey.value();
      if (!apiKey) {
        throw new Error("GEMINI_API_KEY secret is missing");
      }

      const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({
        model: "gemini-2.5-flash",
        generationConfig: {
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        },
      });

      const language = imageData.language || "English";
      const languageInstruction =
        language !== "English"
          ? `\n\nIMPORTANT: Respond in ${language}. All text values in the JSON (defect titles, descriptions, rectification steps, best practices) must be written in ${language}. Keep JSON keys in English.`
          : "";

      const result = await model.generateContent([
        {
          inlineData: {
            data: fileBuffer.toString("base64"),
            mimeType,
          },
        },
        CONSTRUCTION_STAGES_PROMPT + languageInstruction,
      ]);

      const responseText = result?.response?.text?.()?.trim();

      if (!responseText) {
        throw new Error("Gemini returned an empty response");
      }

      const analysisResult = parseGeminiJson(responseText);

      if (analysisResult.error === "NON_CONSTRUCTION_IMAGE") {
        await snap.ref.update({
          status: "error",
          errorMessage: "NON_CONSTRUCTION_IMAGE",
          analyzedAt: FieldValue.serverTimestamp(),
        });
        return null;
      }

      const analysisId = uuidv4();

      const finalResult = {
        ...analysisResult,
        analysis_id: analysisId,
        imageId,
        projectId,
        userId,
        imageUrl: imageData.downloadUrl || null,
        analyzedAt: FieldValue.serverTimestamp(),
      };

      const resultRef = await db
        .collection("users")
        .doc(userId)
        .collection("projects")
        .doc(projectId)
        .collection("analysisResults")
        .add(finalResult);

      await snap.ref.update({
        status: "complete",
        analysisResultId: resultRef.id,
        analyzedAt: FieldValue.serverTimestamp(),
      });

      const defectCount = Array.isArray(analysisResult.defects)
        ? analysisResult.defects.length
        : 0;

      await db
        .collection("users")
        .doc(userId)
        .collection("projects")
        .doc(projectId)
        .set(
          {
            totalAnalyses: FieldValue.increment(1),
            totalDefects: FieldValue.increment(defectCount),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

      await sendNotification({
        userId,
        projectId,
        imageId,
        analysisResultId: resultRef.id,
        analysisResult,
        defectCount,
      });

      logger.info("Analysis complete", { imageId, resultId: resultRef.id });

      return null;
    } catch (error) {
      logger.error("Analysis failed", {
        imageId,
        error: error.message,
        stack: error.stack,
      });

      await snap.ref.update({
        status: "error",
        errorMessage: error.message || "Analysis failed unexpectedly",
        analyzedAt: FieldValue.serverTimestamp(),
      });

      return null;
    }
  },
);

exports.cleanupOrphanedResults = onSchedule(
  { schedule: "0 0 * * *", timeZone: "UTC" },
  async () => {
    logger.info("Running cleanup job");
    return null;
  },
);

function getMimeType(filePath) {
  const ext = filePath.split(".").pop()?.toLowerCase();
  switch (ext) {
    case "jpg":
    case "jpeg":
      return "image/jpeg";
    case "png":
      return "image/png";
    case "webp":
      return "image/webp";
    case "heic":
      return "image/heic";
    case "heif":
      return "image/heif";
    default:
      return "image/jpeg";
  }
}

function parseGeminiJson(responseText) {
  const cleaned = responseText
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
  return JSON.parse(cleaned);
}

async function sendNotification({
  userId,
  projectId,
  imageId,
  analysisResultId,
  analysisResult,
  defectCount,
}) {
  const userDoc = await db.collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) return;

  const assessment = analysisResult.overall_assessment || "WARNING";
  const stage = analysisResult.construction_stage || "Unknown";
  const emoji =
    assessment === "PASS" ? "✅" : assessment === "FAIL" ? "❌" : "⚠️";

  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: `${emoji} Analysis Complete`,
        body: `Stage: ${stage} • ${defectCount} defect${defectCount === 1 ? "" : "s"} found • ${assessment}`,
      },
      data: {
        projectId,
        imageId,
        analysisResultId,
        assessment,
        type: "analysis_complete",
      },
      android: { priority: "high" },
    });
    logger.info("FCM notification sent");
  } catch (error) {
    logger.warn("FCM notification failed", { error: error.message });
  }
}

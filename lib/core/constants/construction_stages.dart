import 'package:flutter/material.dart';

class ConstructionStage {
  final int index;
  final String name;
  final String description;
  final String visualCharacteristics;
  final IconData icon;
  final Color color;

  const ConstructionStage({
    required this.index,
    required this.name,
    required this.description,
    required this.visualCharacteristics,
    required this.icon,
    required this.color,
  });
}

class ConstructionStages {
  ConstructionStages._();

  static const List<String> stageNames = [
    'Site Preparation',
    'Foundation',
    'Plinth',
    'Superstructure / Framing',
    'Brickwork / Masonry',
    'Roofing',
    'Plumbing Rough-in',
    'Electrical Rough-in',
    'Plastering',
    'Flooring',
    'Finishing',
  ];

  static final List<ConstructionStage> stages = [
    ConstructionStage(
      index: 0,
      name: 'Site Preparation',
      description: 'Clearing, grading, and preparing the construction site',
      visualCharacteristics:
          'Cleared land, excavation equipment, soil grading, boundary markings, removal of vegetation and debris, setting out pegs and batter boards',
      icon: Icons.landscape,
      color: const Color(0xFF8D6E63),
    ),
    ConstructionStage(
      index: 1,
      name: 'Foundation',
      description: 'Laying the structural base of the building',
      visualCharacteristics:
          'Excavated trenches, concrete footings, reinforcement bars (rebar) in trenches, formwork, poured concrete at ground level or below, strip foundations or raft slabs',
      icon: Icons.foundation,
      color: const Color(0xFF78909C),
    ),
    ConstructionStage(
      index: 2,
      name: 'Plinth',
      description: 'Constructing the base platform above foundation',
      visualCharacteristics:
          'Concrete or masonry walls just above ground level, damp proof course (DPC) layer, plinth beam visible, backfilling around foundation walls',
      icon: Icons.padding,
      color: const Color(0xFF546E7A),
    ),
    ConstructionStage(
      index: 3,
      name: 'Superstructure / Framing',
      description: 'Erecting the main structural frame above plinth',
      visualCharacteristics:
          'Vertical columns rising from plinth, horizontal beams, concrete frame or steel structure, structural skeleton of the building visible without walls, formwork and scaffolding',
      icon: Icons.architecture,
      color: const Color(0xFF5C6BC0),
    ),
    ConstructionStage(
      index: 4,
      name: 'Brickwork / Masonry',
      description: 'Building walls using bricks or blocks',
      visualCharacteristics:
          'Brick or concrete block walls being laid between columns, mortar joints visible, partially completed wall panels, window and door openings formed, lintel placement',
      icon: Icons.grid_view,
      color: const Color(0xFFEF5350),
    ),
    ConstructionStage(
      index: 5,
      name: 'Roofing',
      description: 'Installing the roof structure and covering',
      visualCharacteristics:
          'Roof slab formwork or timber truss installation, roof deck, waterproofing membrane, roof tiles or metal sheets being fixed, parapet walls, gutters and drainage',
      icon: Icons.roofing,
      color: const Color(0xFF26A69A),
    ),
    ConstructionStage(
      index: 6,
      name: 'Plumbing Rough-in',
      description: 'Installing pipes and drainage systems',
      visualCharacteristics:
          'PVC or metal pipes running through walls and floors, drainage pipes, soil pipes, water supply lines, pipe sleeves in walls, no fixtures installed yet, open walls showing pipe routes',
      icon: Icons.plumbing,
      color: const Color(0xFF29B6F6),
    ),
    ConstructionStage(
      index: 7,
      name: 'Electrical Rough-in',
      description: 'Installing electrical conduits and wiring',
      visualCharacteristics:
          'Electrical conduits in walls and ceilings, junction boxes, switch boxes embedded in walls, wiring running through conduits, consumer unit position, no switches or sockets fitted yet',
      icon: Icons.electrical_services,
      color: const Color(0xFFFFCA28),
    ),
    ConstructionStage(
      index: 8,
      name: 'Plastering',
      description: 'Applying plaster coat to walls and ceilings',
      visualCharacteristics:
          'Wet or dried plaster on walls and ceilings, smooth or textured surface being applied over brickwork, corner beads, plaster drying marks, some areas still unplastered showing brick beneath',
      icon: Icons.brush,
      color: const Color(0xFFAB47BC),
    ),
    ConstructionStage(
      index: 9,
      name: 'Flooring',
      description: 'Installing floor tiles, screed or other finishes',
      visualCharacteristics:
          'Floor tiles being laid, tile adhesive, screed being applied, tile joints being grouted, floor leveling compound, skirting boards, different floor finish materials visible',
      icon: Icons.square_foot,
      color: const Color(0xFF66BB6A),
    ),
    ConstructionStage(
      index: 10,
      name: 'Finishing',
      description: 'Final interior and exterior finishing works',
      visualCharacteristics:
          'Painting, fitted doors and windows, sanitary ware installed, light fittings, switches and sockets fitted, kitchen cabinets, interior decoration, external rendering or cladding, landscaping',
      icon: Icons.home_work,
      color: const Color(0xFFFF7043),
    ),
  ];

  static ConstructionStage? getByName(String name) {
    try {
      return stages.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static ConstructionStage getByIndex(int index) {
    if (index >= 0 && index < stages.length) {
      return stages[index];
    }
    return stages[0];
  }

  static int getIndexByName(String name) {
    final stage = getByName(name);
    return stage?.index ?? 0;
  }

  static double getProgress(String currentStageName) {
    final index = getIndexByName(currentStageName);
    return (index + 1) / stages.length;
  }

  static List<String> getChecklistItems(String stageName) {
    final stage = getByName(stageName);
    if (stage == null) return [];

    switch (stage.index) {
      case 0:
        return [
          'Site boundaries clearly marked',
          'Vegetation and debris removed',
          'Soil grading completed',
          'Site access road established',
          'Temporary drainage installed',
          'Survey pegs and batter boards in place',
          'Soil test report obtained',
          'Local authority approval received',
        ];
      case 1:
        return [
          'Foundation trench dimensions verified',
          'Bearing capacity of soil confirmed',
          'Reinforcement bars correctly placed',
          'Concrete mix design approved',
          'Concrete poured without segregation',
          'Concrete curing in progress',
          'Foundation level checked',
          'Anti-termite treatment applied',
        ];
      case 2:
        return [
          'Plinth beam reinforcement placed',
          'Damp proof course (DPC) installed',
          'Plinth height meets drawings',
          'Backfilling compacted properly',
          'Plinth walls properly bonded',
          'Ground floor slab prepared',
          'Services sleeves in place',
        ];
      case 3:
        return [
          'Column positions verified from drawings',
          'Column reinforcement tied correctly',
          'Beam positions and levels confirmed',
          'Formwork properly supported and braced',
          'Concrete poured and vibrated',
          'Scaffolding safely erected',
          'Structural engineer inspection done',
          'Concrete cube tests taken',
        ];
      case 4:
        return [
          'Brick quality and type approved',
          'Mortar mix ratio correct',
          'Walls plumb and level',
          'Proper bonding pattern used',
          'Window and door openings correct size',
          'Lintels properly installed',
          'Wall ties placed at intervals',
          'Brick joints finished neatly',
        ];
      case 5:
        return [
          'Roof structure level and true',
          'Roof slab thickness correct',
          'Waterproofing membrane applied',
          'Roof drainage slope adequate',
          'Parapet walls properly constructed',
          'Roof tiles or covering fixed securely',
          'Gutters and downpipes installed',
          'Roof insulation installed',
        ];
      case 6:
        return [
          'Pipe routing matches plumbing drawings',
          'Pipe sizes correct for function',
          'All pipes pressure tested',
          'Drainage falls correct',
          'Soil and vent pipes in place',
          'Water supply lines protected',
          'Access panels provided for valves',
          'Pipe clips and supports fixed',
        ];
      case 7:
        return [
          'Electrical layout matches drawings',
          'Conduit sizes adequate',
          'Junction boxes correctly positioned',
          'Switch and socket heights uniform',
          'Earthing provisions made',
          'Consumer unit position agreed',
          'Conduits protected before plastering',
          'Electrical inspector approval obtained',
        ];
      case 8:
        return [
          'Background surface properly prepared',
          'Corner beads installed straight',
          'Plaster thickness uniform',
          'Plaster surface flat and smooth',
          'No cracks or hollow areas',
          'Window sills properly rendered',
          'Plaster curing properly',
          'External render mix correct',
        ];
      case 9:
        return [
          'Floor screed level and flat',
          'Tile adhesive type correct',
          'Tile layout pattern agreed',
          'Tiles level and joints even',
          'Grout applied and finished',
          'Expansion joints provided',
          'Skirting tiles or boards fitted',
          'Floor drain levels correct',
        ];
      case 10:
        return [
          'Painting undercoat applied',
          'Final paint colour matches spec',
          'All doors and windows fit properly',
          'Ironmongery fitted and functioning',
          'Sanitary ware installed correctly',
          'Light fittings and switches working',
          'Kitchen units installed level',
          'Snagging list completed and signed off',
        ];
      default:
        return [];
    }
  }
}

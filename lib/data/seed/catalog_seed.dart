/// Catalog seed data — source: docs/opravila-in-rastline.md
/// Loaded once by SeedService (M1.5) on first launch; never modified at runtime.
library;

class TaskTypeSeed {
  const TaskTypeSeed({
    required this.id,
    required this.sl,
    required this.en,
    required this.de,
    required this.icon,
    required this.category,
    this.requiresSubject = false,
    this.weatherSensitive = false,
    this.consumesSupplies = false,
    this.defaultCadence,
  });

  final String id;
  final String sl;
  final String en;
  final String de;
  final String icon;
  final String category;
  final bool requiresSubject;
  final bool weatherSensitive;
  // Draws from stock (fertilizing, treatment) — gates the supplies step
  final bool consumesSupplies;
  // Days between repetitions; null = no fixed cadence
  final int? defaultCadence;
}

class PlantSeed {
  const PlantSeed({
    required this.id,
    required this.sl,
    required this.en,
    required this.de,
    required this.icon,
    required this.category,
    this.scientificName,
  });

  final String id;
  final String sl;
  final String en;
  final String de;
  final String icon;
  final String category;
  final String? scientificName;
}

abstract final class CatalogSeed {
  // ---------------------------------------------------------------------------
  // Task types  (docs/opravila-in-rastline.md §A)
  // category = task group; requires_subject / weather_sensitive per §A tables
  // ---------------------------------------------------------------------------
  static const taskTypes = <TaskTypeSeed>[
    // A.1 — Core (all gardens)
    TaskTypeSeed(id: 'mow', sl: 'Košnja', en: 'Mowing', de: 'Mähen',
        icon: '🌱', category: 'lawn_care',
        weatherSensitive: true, defaultCadence: 7),
    TaskTypeSeed(id: 'water', sl: 'Zalivanje', en: 'Watering', de: 'Gießen',
        icon: '💧', category: 'general', weatherSensitive: true),
    TaskTypeSeed(id: 'fertilize', sl: 'Gnojenje', en: 'Fertilizing', de: 'Düngen',
        icon: '🧪', category: 'plant_care',
        weatherSensitive: true, consumesSupplies: true),
    TaskTypeSeed(id: 'prune', sl: 'Obrez', en: 'Pruning', de: 'Schnitt',
        icon: '✂️', category: 'plant_care', requiresSubject: true),
    TaskTypeSeed(id: 'plant', sl: 'Sajenje', en: 'Planting', de: 'Pflanzen',
        icon: '🪴', category: 'planting',
        requiresSubject: true, weatherSensitive: true),
    TaskTypeSeed(id: 'sow', sl: 'Setev', en: 'Sowing', de: 'Aussaat',
        icon: '🌾', category: 'planting',
        requiresSubject: true, weatherSensitive: true),
    TaskTypeSeed(id: 'treat', sl: 'Tretiranje / škropljenje', en: 'Treatment',
        de: 'Behandlung', icon: '🐛', category: 'protection',
        requiresSubject: true, weatherSensitive: true, consumesSupplies: true),
    TaskTypeSeed(id: 'harvest', sl: 'Pobiranje', en: 'Harvest', de: 'Ernte',
        icon: '🧺', category: 'harvest', requiresSubject: true),
    TaskTypeSeed(id: 'weed', sl: 'Pletje / okopavanje', en: 'Weeding',
        de: 'Jäten', icon: '🌿', category: 'general'),
    TaskTypeSeed(id: 'mulch', sl: 'Zastiranje', en: 'Mulching', de: 'Mulchen',
        icon: '🍂', category: 'soil_care'),
    TaskTypeSeed(id: 'graft', sl: 'Cepljenje', en: 'Grafting',
        de: 'Veredeln / Pfropfen', icon: '🔗', category: 'plant_care',
        requiresSubject: true),

    // A.2 — Lawn-care specific
    TaskTypeSeed(id: 'aerate', sl: 'Prezračevanje (aeriranje)', en: 'Aeration',
        de: 'Aerifizieren', icon: '🕳️',
        category: 'lawn_care', weatherSensitive: true),
    TaskTypeSeed(id: 'scarify', sl: 'Vertikutiranje (rezkanje ruše)',
        en: 'Scarifying', de: 'Vertikutieren', icon: '🪮',
        category: 'lawn_care', weatherSensitive: true),
    TaskTypeSeed(id: 'overseed', sl: 'Dosejevanje', en: 'Overseeding',
        de: 'Nachsaat', icon: '🌱',
        category: 'lawn_care', weatherSensitive: true),
    TaskTypeSeed(id: 'topdress', sl: 'Peskanje (top-dressing)', en: 'Top-dressing',
        de: 'Topdressing', icon: '🏖️', category: 'lawn_care'),
    TaskTypeSeed(id: 'roll', sl: 'Valjanje', en: 'Rolling', de: 'Walzen',
        icon: '🛞', category: 'lawn_care', weatherSensitive: true),
    TaskTypeSeed(id: 'lime', sl: 'Apnjenje', en: 'Liming', de: 'Kalken',
        icon: '⚪', category: 'lawn_care', consumesSupplies: true),
    TaskTypeSeed(id: 'lawn_weed_moss', sl: 'Tretiranje proti plevelu/mahu',
        en: 'Weed & moss control', de: 'Unkraut-/Moosbekämpfung', icon: '🚫',
        category: 'lawn_care', weatherSensitive: true, consumesSupplies: true),

    // A.3 — Seedling cultivation (protected areas — frost-anchor chain)
    TaskTypeSeed(id: 'start_seedlings', sl: 'Predsetev / vzgoja sadik',
        en: 'Starting seedlings (indoor sow)', de: 'Voranzucht', icon: '🪴',
        category: 'seedling_care', requiresSubject: true),
    TaskTypeSeed(id: 'prick_out', sl: 'Pikiranje', en: 'Pricking out / Potting on',
        de: 'Pikieren', icon: '🌿',
        category: 'seedling_care', requiresSubject: true),
    TaskTypeSeed(id: 'harden_off', sl: 'Utrjevanje (zakaljevanje)',
        en: 'Hardening off', de: 'Abhärten', icon: '🌤️',
        category: 'seedling_care', requiresSubject: true, weatherSensitive: true),
    TaskTypeSeed(id: 'transplant', sl: 'Presaditev na prosto',
        en: 'Transplanting out', de: 'Auspflanzen', icon: '🌱',
        category: 'planting', requiresSubject: true, weatherSensitive: true),

    // A.4 — Additional care / seasonal protection
    TaskTypeSeed(id: 'stake', sl: 'Privezovanje / opora', en: 'Staking / Tying',
        de: 'Aufbinden / Stützen', icon: '🪵',
        category: 'plant_care', requiresSubject: true),
    TaskTypeSeed(id: 'thin_fruit', sl: 'Redčenje plodov', en: 'Fruit thinning',
        de: 'Ausdünnen', icon: '🍏',
        category: 'plant_care', requiresSubject: true),
    TaskTypeSeed(id: 'repot', sl: 'Presaditev lončnic', en: 'Repotting',
        de: 'Umtopfen', icon: '🪴',
        category: 'plant_care', requiresSubject: true),
    TaskTypeSeed(id: 'overwinter', sl: 'Prezimovanje / zaščita pred zmrzaljo',
        en: 'Overwintering / Frost protection', de: 'Überwintern / Frostschutz',
        icon: '❄️', category: 'protection',
        requiresSubject: true, weatherSensitive: true),
  ];

  // ---------------------------------------------------------------------------
  // Plants  (docs/opravila-in-rastline.md §C)
  // ~34 sample entries; full catalog (100–200+) seeded from Wikidata/GBIF later
  // ---------------------------------------------------------------------------
  static const plants = <PlantSeed>[
    // C.1 — Sadno drevje (fruit trees)
    PlantSeed(id: 'apple', sl: 'jablana', en: 'apple', de: 'Apfel',
        icon: '🍎', category: 'fruit_tree', scientificName: 'Malus domestica'),
    PlantSeed(id: 'pear', sl: 'hruška', en: 'pear', de: 'Birne',
        icon: '🍐', category: 'fruit_tree', scientificName: 'Pyrus communis'),
    PlantSeed(id: 'plum', sl: 'sliva', en: 'plum', de: 'Pflaume / Zwetschge',
        icon: '🫐', category: 'fruit_tree', scientificName: 'Prunus domestica'),
    PlantSeed(id: 'cherry', sl: 'češnja', en: 'cherry', de: 'Kirsche',
        icon: '🍒', category: 'fruit_tree', scientificName: 'Prunus avium'),
    PlantSeed(id: 'peach', sl: 'breskev', en: 'peach', de: 'Pfirsich',
        icon: '🍑', category: 'fruit_tree', scientificName: 'Prunus persica'),

    // C.2 — Jagodičevje (berries)
    PlantSeed(id: 'raspberry', sl: 'malina', en: 'raspberry', de: 'Himbeere',
        icon: '🍇', category: 'berries', scientificName: 'Rubus idaeus'),
    PlantSeed(id: 'strawberry', sl: 'jagoda', en: 'strawberry', de: 'Erdbeere',
        icon: '🍓', category: 'berries', scientificName: 'Fragaria × ananassa'),
    PlantSeed(id: 'currant', sl: 'ribez', en: 'currant', de: 'Johannisbeere',
        icon: '🔴', category: 'berries', scientificName: 'Ribes rubrum'),
    PlantSeed(id: 'blueberry', sl: 'borovnica', en: 'blueberry', de: 'Heidelbeere',
        icon: '🫐', category: 'berries', scientificName: 'Vaccinium corymbosum'),

    // C.3 — Zelenjava (vegetables)
    PlantSeed(id: 'tomato', sl: 'paradižnik', en: 'tomato', de: 'Tomate',
        icon: '🍅', category: 'vegetable', scientificName: 'Solanum lycopersicum'),
    PlantSeed(id: 'lettuce', sl: 'solata', en: 'lettuce', de: 'Salat',
        icon: '🥬', category: 'vegetable', scientificName: 'Lactuca sativa'),
    PlantSeed(id: 'potato', sl: 'krompir', en: 'potato', de: 'Kartoffel',
        icon: '🥔', category: 'vegetable', scientificName: 'Solanum tuberosum'),
    PlantSeed(id: 'radish', sl: 'redkvica', en: 'radish', de: 'Radieschen',
        icon: '🌶️', category: 'vegetable', scientificName: 'Raphanus sativus'),
    PlantSeed(id: 'cucumber', sl: 'kumara', en: 'cucumber', de: 'Gurke',
        icon: '🥒', category: 'vegetable', scientificName: 'Cucumis sativus'),
    PlantSeed(id: 'pepper', sl: 'paprika', en: 'pepper', de: 'Paprika',
        icon: '🫑', category: 'vegetable', scientificName: 'Capsicum annuum'),
    PlantSeed(id: 'bean', sl: 'fižol', en: 'bean', de: 'Bohne',
        icon: '🫘', category: 'vegetable', scientificName: 'Phaseolus vulgaris'),
    PlantSeed(id: 'carrot', sl: 'korenje', en: 'carrot', de: 'Karotte / Möhre',
        icon: '🥕', category: 'vegetable', scientificName: 'Daucus carota'),
    PlantSeed(id: 'cabbage', sl: 'zelje', en: 'cabbage', de: 'Kohl',
        icon: '🥬', category: 'vegetable', scientificName: 'Brassica oleracea'),
    PlantSeed(id: 'zucchini', sl: 'bučke', en: 'zucchini', de: 'Zucchini',
        icon: '🥒', category: 'vegetable', scientificName: 'Cucurbita pepo'),
    PlantSeed(id: 'onion', sl: 'čebula', en: 'onion', de: 'Zwiebel',
        icon: '🧅', category: 'vegetable', scientificName: 'Allium cepa'),
    PlantSeed(id: 'garlic', sl: 'česen', en: 'garlic', de: 'Knoblauch',
        icon: '🧄', category: 'vegetable', scientificName: 'Allium sativum'),

    // C.4 — Zelišča (herbs)
    PlantSeed(id: 'basil', sl: 'bazilika', en: 'basil', de: 'Basilikum',
        icon: '🌿', category: 'herbs', scientificName: 'Ocimum basilicum'),
    PlantSeed(id: 'parsley', sl: 'peteršilj', en: 'parsley', de: 'Petersilie',
        icon: '🌿', category: 'herbs', scientificName: 'Petroselinum crispum'),
    PlantSeed(id: 'rosemary', sl: 'rožmarin', en: 'rosemary', de: 'Rosmarin',
        icon: '🌿', category: 'herbs', scientificName: 'Salvia rosmarinus'),
    PlantSeed(id: 'thyme', sl: 'timijan', en: 'thyme', de: 'Thymian',
        icon: '🌿', category: 'herbs', scientificName: 'Thymus vulgaris'),
    PlantSeed(id: 'sage', sl: 'žajbelj', en: 'sage', de: 'Salbei',
        icon: '🌿', category: 'herbs', scientificName: 'Salvia officinalis'),
    PlantSeed(id: 'chives', sl: 'drobnjak', en: 'chives', de: 'Schnittlauch',
        icon: '🌿', category: 'herbs', scientificName: 'Allium schoenoprasum'),

    // C.5 — Okrasne / živa meja (ornamental / hedge)
    PlantSeed(id: 'cherry_laurel', sl: 'lovorikovec (češnjev lovor)',
        en: 'cherry laurel', de: 'Kirschlorbeer',
        icon: '🌿', category: 'ornamental', scientificName: 'Prunus laurocerasus'),
    PlantSeed(id: 'thuja', sl: 'tuja', en: 'thuja', de: 'Thuja / Lebensbaum',
        icon: '🌲', category: 'ornamental', scientificName: 'Thuja occidentalis'),
    PlantSeed(id: 'hornbeam', sl: 'gaber', en: 'hornbeam', de: 'Hainbuche',
        icon: '🌳', category: 'ornamental', scientificName: 'Carpinus betulus'),
    PlantSeed(id: 'beech', sl: 'bukev', en: 'beech', de: 'Buche',
        icon: '🌳', category: 'ornamental', scientificName: 'Fagus sylvatica'),
    PlantSeed(id: 'box', sl: 'pušpan', en: 'box', de: 'Buchsbaum',
        icon: '🌿', category: 'ornamental', scientificName: 'Buxus sempervirens'),
    PlantSeed(id: 'rose', sl: 'vrtnica', en: 'rose', de: 'Rose',
        icon: '🌹', category: 'ornamental', scientificName: 'Rosa'),

    // C.6 — Trava / trata (lawn grass)
    PlantSeed(id: 'lawn_grass', sl: 'travna ruša (mešanica)', en: 'lawn grass',
        de: 'Rasen', icon: '🌱', category: 'lawn',
        scientificName: 'Lolium perenne, Poa pratensis, Festuca'),
  ];

  // ---------------------------------------------------------------------------
  // Category ↔ task type matrix  (docs/opravila-in-rastline.md §B)
  // (plant category, task_type_id) — which task types apply per plant category
  // ---------------------------------------------------------------------------
  static const categoryMatrix = <(String, String)>[
    // lawn
    ('lawn', 'mow'), ('lawn', 'water'), ('lawn', 'fertilize'),
    ('lawn', 'aerate'), ('lawn', 'scarify'), ('lawn', 'overseed'),
    ('lawn', 'topdress'), ('lawn', 'roll'), ('lawn', 'lime'),
    ('lawn', 'lawn_weed_moss'),
    // fruit_tree
    ('fruit_tree', 'prune'), ('fruit_tree', 'graft'),
    ('fruit_tree', 'thin_fruit'), ('fruit_tree', 'treat'),
    ('fruit_tree', 'fertilize'), ('fruit_tree', 'harvest'),
    ('fruit_tree', 'water'), ('fruit_tree', 'mulch'),
    // berries
    ('berries', 'prune'), ('berries', 'treat'), ('berries', 'fertilize'),
    ('berries', 'harvest'), ('berries', 'water'), ('berries', 'mulch'),
    // vegetable
    ('vegetable', 'start_seedlings'), ('vegetable', 'prick_out'),
    ('vegetable', 'harden_off'), ('vegetable', 'transplant'),
    ('vegetable', 'sow'), ('vegetable', 'plant'), ('vegetable', 'stake'),
    ('vegetable', 'water'), ('vegetable', 'fertilize'), ('vegetable', 'weed'),
    ('vegetable', 'treat'), ('vegetable', 'harvest'), ('vegetable', 'mulch'),
    // herbs
    ('herbs', 'start_seedlings'), ('herbs', 'prick_out'),
    ('herbs', 'harden_off'), ('herbs', 'transplant'),
    ('herbs', 'plant'), ('herbs', 'sow'),
    ('herbs', 'water'), ('herbs', 'harvest'),
    // ornamental
    ('ornamental', 'prune'), ('ornamental', 'treat'), ('ornamental', 'fertilize'),
    ('ornamental', 'water'), ('ornamental', 'plant'), ('ornamental', 'graft'),
    ('ornamental', 'overwinter'),
    // container
    ('container', 'repot'), ('container', 'water'), ('container', 'fertilize'),
    ('container', 'overwinter'), ('container', 'stake'),
  ];
}

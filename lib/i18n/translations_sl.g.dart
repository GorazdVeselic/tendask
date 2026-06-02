///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsSl = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.sl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$nav$sl nav = Translations$nav$sl.internal(_root);
	late final Translations$home$sl home = Translations$home$sl.internal(_root);
	late final Translations$common$sl common = Translations$common$sl.internal(_root);
	late final Translations$quick_log$sl quick_log = Translations$quick_log$sl.internal(_root);
}

// Path: nav
class Translations$nav$sl {
	Translations$nav$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Domov'
	String get home => 'Domov';

	/// sl: 'Dnevnik'
	String get journal => 'Dnevnik';

	/// sl: 'Opravila'
	String get tasks => 'Opravila';
}

// Path: home
class Translations$home$sl {
	Translations$home$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Dober dan 🌿'
	String get greeting => 'Dober dan 🌿';

	/// sl: 'Danes'
	String get today => 'Danes';

	/// sl: 'Nazadnje'
	String get recent => 'Nazadnje';

	/// sl: 'Danes ni načrtovanih opravil.'
	String get no_tasks_today => 'Danes ni načrtovanih opravil.';

	/// sl: 'Še ni opravljenih opravil.'
	String get no_recent => 'Še ni opravljenih opravil.';

	/// sl: 'Vreme bo na voljo v M4.'
	String get weather_placeholder => 'Vreme bo na voljo v M4.';
}

// Path: common
class Translations$common$sl {
	Translations$common$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'danes'
	String get today => 'danes';

	/// sl: 'včeraj'
	String get yesterday => 'včeraj';
}

// Path: quick_log
class Translations$quick_log$sl {
	Translations$quick_log$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Hiter vnos'
	String get title => 'Hiter vnos';

	/// sl: 'Napredno ›'
	String get advanced => 'Napredno ›';

	/// sl: 'Nimaš opravila, le zapis?'
	String get note_card_title => 'Nimaš opravila, le zapis?';

	/// sl: 'Misel, opažanje, bolezen…'
	String get note_card_sub => 'Misel, opažanje, bolezen…';

	/// sl: 'Opomba ›'
	String get note_card_action => 'Opomba ›';

	/// sl: 'Kaj si naredil?'
	String get what => 'Kaj si naredil?';

	/// sl: 'Kdaj'
	String get when => 'Kdaj';

	/// sl: 'Danes'
	String get today => 'Danes';

	/// sl: 'Včeraj'
	String get yesterday => 'Včeraj';

	/// sl: 'Datum…'
	String get pick_date => 'Datum…';

	/// sl: 'Kje'
	String get where => 'Kje';

	/// sl: 'Ni območij — dodaj jih v razdelku Območja.'
	String get no_areas => 'Ni območij — dodaj jih v razdelku Območja.';

	/// sl: 'Več (po potrebi)'
	String get more => 'Več (po potrebi)';

	/// sl: '🌿 Dodaj rastlino'
	String get add_plant => '🌿 Dodaj rastlino';

	/// sl: '🧪 Dodaj sredstvo iz zalog'
	String get add_supply => '🧪 Dodaj sredstvo iz zalog';

	/// sl: '🔔 Dodaj opomnik'
	String get add_reminder => '🔔 Dodaj opomnik';

	/// sl: 'Opomba (neobvezno)'
	String get note_label => 'Opomba (neobvezno)';

	/// sl: 'npr. 100g uree na 16l'
	String get note_hint => 'npr. 100g uree na 16l';

	/// sl: 'Shrani opravilo'
	String get save => 'Shrani opravilo';

	/// sl: 'Izberi vrsto opravila.'
	String get err_type => 'Izberi vrsto opravila.';

	/// sl: 'Izberi območje.'
	String get err_area => 'Izberi območje.';
}

/// The flat map containing all translations for locale <sl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.home' => 'Domov',
			'nav.journal' => 'Dnevnik',
			'nav.tasks' => 'Opravila',
			'home.greeting' => 'Dober dan 🌿',
			'home.today' => 'Danes',
			'home.recent' => 'Nazadnje',
			'home.no_tasks_today' => 'Danes ni načrtovanih opravil.',
			'home.no_recent' => 'Še ni opravljenih opravil.',
			'home.weather_placeholder' => 'Vreme bo na voljo v M4.',
			'common.today' => 'danes',
			'common.yesterday' => 'včeraj',
			'quick_log.title' => 'Hiter vnos',
			'quick_log.advanced' => 'Napredno ›',
			'quick_log.note_card_title' => 'Nimaš opravila, le zapis?',
			'quick_log.note_card_sub' => 'Misel, opažanje, bolezen…',
			'quick_log.note_card_action' => 'Opomba ›',
			'quick_log.what' => 'Kaj si naredil?',
			'quick_log.when' => 'Kdaj',
			'quick_log.today' => 'Danes',
			'quick_log.yesterday' => 'Včeraj',
			'quick_log.pick_date' => 'Datum…',
			'quick_log.where' => 'Kje',
			'quick_log.no_areas' => 'Ni območij — dodaj jih v razdelku Območja.',
			'quick_log.more' => 'Več (po potrebi)',
			'quick_log.add_plant' => '🌿 Dodaj rastlino',
			'quick_log.add_supply' => '🧪 Dodaj sredstvo iz zalog',
			'quick_log.add_reminder' => '🔔 Dodaj opomnik',
			'quick_log.note_label' => 'Opomba (neobvezno)',
			'quick_log.note_hint' => 'npr. 100g uree na 16l',
			'quick_log.save' => 'Shrani opravilo',
			'quick_log.err_type' => 'Izberi vrsto opravila.',
			'quick_log.err_area' => 'Izberi območje.',
			_ => null,
		};
	}
}

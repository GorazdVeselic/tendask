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
	late final Translations$journal$sl journal = Translations$journal$sl.internal(_root);
	late final Translations$quick_log$sl quick_log = Translations$quick_log$sl.internal(_root);
	late final Translations$tasks_list$sl tasks_list = Translations$tasks_list$sl.internal(_root);
	late final Translations$task_form$sl task_form = Translations$task_form$sl.internal(_root);
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

	/// sl: 'Danes'
	String get today => 'Danes';

	/// sl: 'danes'
	String get today_lower => 'danes';

	/// sl: 'včeraj'
	String get yesterday => 'včeraj';
}

// Path: journal
class Translations$journal$sl {
	Translations$journal$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Dnevnik'
	String get title => 'Dnevnik';

	/// sl: 'vrtni dnevnik'
	String get subtitle => 'vrtni dnevnik';

	/// sl: 'Vse'
	String get filter_all => 'Vse';

	/// sl: '✓ Opravila'
	String get filter_tasks => '✓ Opravila';

	/// sl: '✍️ Opombe'
	String get filter_notes => '✍️ Opombe';

	/// sl: 'Ni vnosov v dnevniku.'
	String get empty => 'Ni vnosov v dnevniku.';

	/// sl: 'Ni opravljenih opravil.'
	String get empty_tasks => 'Ni opravljenih opravil.';

	/// sl: 'Ni opomb.'
	String get empty_notes => 'Ni opomb.';

	/// sl: 'Časovnica'
	String get timeline => 'Časovnica';

	/// sl: 'Mesec'
	String get month_view => 'Mesec';
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

// Path: tasks_list
class Translations$tasks_list$sl {
	Translations$tasks_list$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Opravila'
	String get title => 'Opravila';

	/// sl: 'prihajajoča in zapadla'
	String get subtitle => 'prihajajoča in zapadla';

	/// sl: 'Zamuda'
	String get section_overdue => 'Zamuda';

	/// sl: 'Danes'
	String get section_today => 'Danes';

	/// sl: 'Jutri'
	String get section_tomorrow => 'Jutri';

	/// sl: 'Ta teden'
	String get section_this_week => 'Ta teden';

	/// sl: 'Pozneje'
	String get section_later => 'Pozneje';

	/// sl: 'Ni čakajočih opravil. Dodaj novo z +.'
	String get empty => 'Ni čakajočih opravil. Dodaj novo z +.';

	/// sl: '(one) {zamuja 1 dan} (other) {zamuja {n} dni}'
	String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: 'zamuja 1 dan',
		other: 'zamuja {n} dni',
	);

	/// sl: 'danes'
	String get status_today => 'danes';

	/// sl: 'jutri'
	String get status_tomorrow => 'jutri';

	/// sl: 'Opravljeno'
	String get action_complete => 'Opravljeno';

	/// sl: '+1 dan'
	String get action_postpone => '+1 dan';

	/// sl: 'Uredi'
	String get action_edit => 'Uredi';

	/// sl: 'Podvoji'
	String get action_duplicate => 'Podvoji';

	/// sl: 'Izbriši'
	String get action_delete => 'Izbriši';

	/// sl: 'Izbriši opravilo?'
	String get delete_confirm_title => 'Izbriši opravilo?';

	/// sl: 'To dejanje je nepopravljivo.'
	String get delete_confirm_body => 'To dejanje je nepopravljivo.';

	/// sl: 'Izbriši'
	String get delete_yes => 'Izbriši';

	/// sl: 'Prekliči'
	String get delete_cancel => 'Prekliči';
}

// Path: task_form
class Translations$task_form$sl {
	Translations$task_form$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Novo opravilo'
	String get title_new => 'Novo opravilo';

	/// sl: 'Uredi opravilo'
	String get title_edit => 'Uredi opravilo';

	/// sl: 'Kaj'
	String get what => 'Kaj';

	/// sl: 'Izberi vrsto opravila'
	String get what_hint => 'Izberi vrsto opravila';

	/// sl: 'Kdaj'
	String get when => 'Kdaj';

	/// sl: 'Status'
	String get status => 'Status';

	/// sl: 'Čaka'
	String get status_waiting => 'Čaka';

	/// sl: 'Opravljeno'
	String get status_done => 'Opravljeno';

	/// sl: 'Območje'
	String get area => 'Območje';

	/// sl: 'Ni območij — dodaj jih v razdelku Območja.'
	String get no_areas => 'Ni območij — dodaj jih v razdelku Območja.';

	/// sl: 'Rastlina'
	String get plant => 'Rastlina';

	/// sl: '(za obrez, tretiranje, pobiranje…)'
	String get plant_hint => '(za obrez, tretiranje, pobiranje…)';

	/// sl: '+ Izberi rastlino'
	String get plant_add => '+ Izberi rastlino';

	/// sl: 'Vežemo na rastlino, ne le območje.'
	String get plant_note => 'Vežemo na rastlino, ne le območje.';

	/// sl: 'Sredstva iz zalog (poraba)'
	String get supplies => 'Sredstva iz zalog (poraba)';

	/// sl: '+ Dodaj sredstvo iz zalog'
	String get supplies_add => '+ Dodaj sredstvo iz zalog';

	/// sl: 'Opomnik (neobvezno)'
	String get reminders => 'Opomnik (neobvezno)';

	/// sl: '+ Dodaj obvestilo'
	String get reminders_add => '+ Dodaj obvestilo';

	/// sl: 'Ponavljanje'
	String get recurrence => 'Ponavljanje';

	/// sl: 'Enkratno'
	String get recurrence_once => 'Enkratno';

	/// sl: 'Tedensko'
	String get recurrence_weekly => 'Tedensko';

	/// sl: 'Sezonsko'
	String get recurrence_seasonal => 'Sezonsko';

	/// sl: 'Opomba (neobvezno)'
	String get note => 'Opomba (neobvezno)';

	/// sl: 'Zjutraj, pred napovedanim dežjem.'
	String get note_hint => 'Zjutraj, pred napovedanim dežjem.';

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
			'common.today' => 'Danes',
			'common.today_lower' => 'danes',
			'common.yesterday' => 'včeraj',
			'journal.title' => 'Dnevnik',
			'journal.subtitle' => 'vrtni dnevnik',
			'journal.filter_all' => 'Vse',
			'journal.filter_tasks' => '✓ Opravila',
			'journal.filter_notes' => '✍️ Opombe',
			'journal.empty' => 'Ni vnosov v dnevniku.',
			'journal.empty_tasks' => 'Ni opravljenih opravil.',
			'journal.empty_notes' => 'Ni opomb.',
			'journal.timeline' => 'Časovnica',
			'journal.month_view' => 'Mesec',
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
			'tasks_list.title' => 'Opravila',
			'tasks_list.subtitle' => 'prihajajoča in zapadla',
			'tasks_list.section_overdue' => 'Zamuda',
			'tasks_list.section_today' => 'Danes',
			'tasks_list.section_tomorrow' => 'Jutri',
			'tasks_list.section_this_week' => 'Ta teden',
			'tasks_list.section_later' => 'Pozneje',
			'tasks_list.empty' => 'Ni čakajočih opravil. Dodaj novo z +.',
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n, one: 'zamuja 1 dan', other: 'zamuja {n} dni', ), 
			'tasks_list.status_today' => 'danes',
			'tasks_list.status_tomorrow' => 'jutri',
			'tasks_list.action_complete' => 'Opravljeno',
			'tasks_list.action_postpone' => '+1 dan',
			'tasks_list.action_edit' => 'Uredi',
			'tasks_list.action_duplicate' => 'Podvoji',
			'tasks_list.action_delete' => 'Izbriši',
			'tasks_list.delete_confirm_title' => 'Izbriši opravilo?',
			'tasks_list.delete_confirm_body' => 'To dejanje je nepopravljivo.',
			'tasks_list.delete_yes' => 'Izbriši',
			'tasks_list.delete_cancel' => 'Prekliči',
			'task_form.title_new' => 'Novo opravilo',
			'task_form.title_edit' => 'Uredi opravilo',
			'task_form.what' => 'Kaj',
			'task_form.what_hint' => 'Izberi vrsto opravila',
			'task_form.when' => 'Kdaj',
			'task_form.status' => 'Status',
			'task_form.status_waiting' => 'Čaka',
			'task_form.status_done' => 'Opravljeno',
			'task_form.area' => 'Območje',
			'task_form.no_areas' => 'Ni območij — dodaj jih v razdelku Območja.',
			'task_form.plant' => 'Rastlina',
			'task_form.plant_hint' => '(za obrez, tretiranje, pobiranje…)',
			'task_form.plant_add' => '+ Izberi rastlino',
			'task_form.plant_note' => 'Vežemo na rastlino, ne le območje.',
			'task_form.supplies' => 'Sredstva iz zalog (poraba)',
			'task_form.supplies_add' => '+ Dodaj sredstvo iz zalog',
			'task_form.reminders' => 'Opomnik (neobvezno)',
			'task_form.reminders_add' => '+ Dodaj obvestilo',
			'task_form.recurrence' => 'Ponavljanje',
			'task_form.recurrence_once' => 'Enkratno',
			'task_form.recurrence_weekly' => 'Tedensko',
			'task_form.recurrence_seasonal' => 'Sezonsko',
			'task_form.note' => 'Opomba (neobvezno)',
			'task_form.note_hint' => 'Zjutraj, pred napovedanim dežjem.',
			'task_form.save' => 'Shrani opravilo',
			'task_form.err_type' => 'Izberi vrsto opravila.',
			'task_form.err_area' => 'Izberi območje.',
			_ => null,
		};
	}
}

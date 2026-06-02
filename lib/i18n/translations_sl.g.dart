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
	late final Translations$notes$sl notes = Translations$notes$sl.internal(_root);
	late final Translations$task_detail$sl task_detail = Translations$task_detail$sl.internal(_root);
	late final Translations$tasks_list$sl tasks_list = Translations$tasks_list$sl.internal(_root);
	late final Translations$task_form$sl task_form = Translations$task_form$sl.internal(_root);
	late final Translations$areas$sl areas = Translations$areas$sl.internal(_root);
	late final Translations$plants$sl plants = Translations$plants$sl.internal(_root);
	late final Translations$supplies$sl supplies = Translations$supplies$sl.internal(_root);
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

	/// sl: 'Območja'
	String get areas => 'Območja';

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

// Path: notes
class Translations$notes$sl {
	Translations$notes$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Nova opomba'
	String get title_new => 'Nova opomba';

	/// sl: 'Uredi opombo'
	String get title_edit => 'Uredi opombo';

	/// sl: 'Zapis'
	String get content_label => 'Zapis';

	/// sl: 'Prosto besedilo — opažanje, ideja, misel…'
	String get content_hint => 'Prosto besedilo — opažanje, ideja, misel…';

	/// sl: 'Kdaj'
	String get when => 'Kdaj';

	/// sl: 'Danes'
	String get today => 'Danes';

	/// sl: 'Včeraj'
	String get yesterday => 'Včeraj';

	/// sl: 'Datum…'
	String get pick_date => 'Datum…';

	/// sl: 'Območje (neobvezno)'
	String get area => 'Območje (neobvezno)';

	/// sl: 'Ni območij — dodaj jih v razdelku Območja.'
	String get no_areas => 'Ni območij — dodaj jih v razdelku Območja.';

	/// sl: 'Rastlina (neobvezno)'
	String get plant => 'Rastlina (neobvezno)';

	/// sl: 'Shrani opombo'
	String get save => 'Shrani opombo';

	/// sl: 'Vpiši besedilo opombe.'
	String get err_content => 'Vpiši besedilo opombe.';

	/// sl: 'Izbriši opombo'
	String get delete => 'Izbriši opombo';

	/// sl: 'To dejanje je nepopravljivo.'
	String get delete_confirm => 'To dejanje je nepopravljivo.';

	/// sl: '🌧️ Vreme se shrani samodejno.'
	String get info => '🌧️ Vreme se shrani samodejno.';
}

// Path: task_detail
class Translations$task_detail$sl {
	Translations$task_detail$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Vremenski posnetek'
	String get section_weather => 'Vremenski posnetek';

	/// sl: 'Vremenski posnetek bo na voljo v M4.'
	String get weather_placeholder => 'Vremenski posnetek bo na voljo v M4.';

	/// sl: 'Podrobnosti'
	String get section_details => 'Podrobnosti';

	/// sl: 'Območje'
	String get label_area => 'Območje';

	/// sl: 'Rastlina'
	String get label_plant => 'Rastlina';

	/// sl: 'Sredstva'
	String get label_supplies => 'Sredstva';

	/// sl: 'Opomnik'
	String get label_reminder => 'Opomnik';

	/// sl: 'Ponavljanje'
	String get label_recurrence => 'Ponavljanje';

	/// sl: 'Opomba'
	String get label_note => 'Opomba';

	/// sl: 'Načrtovano'
	String get badge_waiting => 'Načrtovano';

	/// sl: 'Opravljeno'
	String get badge_done => 'Opravljeno';

	/// sl: '✓ Označi kot opravljeno'
	String get action_complete => '✓  Označi kot opravljeno';

	/// sl: '+1 dan'
	String get action_postpone => '+1 dan';

	/// sl: 'Uredi'
	String get action_edit => 'Uredi';

	/// sl: 'Podvoji'
	String get action_duplicate => 'Podvoji';

	/// sl: 'Izbriši'
	String get action_delete => 'Izbriši';

	/// sl: 'Na čaka'
	String get action_revert => 'Na čaka';

	/// sl: 'Premakni'
	String get action_move => 'Premakni';

	/// sl: 'Enkratno'
	String get recurrence_once => 'Enkratno';

	/// sl: 'Tedensko'
	String get recurrence_weekly => 'Tedensko';

	/// sl: 'Sezonsko'
	String get recurrence_seasonal => 'Sezonsko';

	/// sl: '—'
	String get none => '—';

	/// sl: 'Opravilo ni bilo najdeno.'
	String get not_found => 'Opravilo ni bilo najdeno.';
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

	/// sl: 'Izberi rastlino'
	String get plant_select => 'Izberi rastlino';

	/// sl: 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.'
	String get plant_none => 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.';

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

// Path: areas
class Translations$areas$sl {
	Translations$areas$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Območja'
	String get title => 'Območja';

	/// sl: 'moja posest'
	String get subtitle => 'moja posest';

	/// sl: 'Ni območij. Dodaj prvo z +.'
	String get empty => 'Ni območij. Dodaj prvo z +.';

	/// sl: 'zadnje:'
	String get last_prefix => 'zadnje:';

	/// sl: 'Trata'
	String get type_lawn => 'Trata';

	/// sl: 'Živa meja'
	String get type_hedge => 'Živa meja';

	/// sl: 'Gredica'
	String get type_bed => 'Gredica';

	/// sl: 'Sadno drevje'
	String get type_tree => 'Sadno drevje';

	/// sl: 'Okrasno'
	String get type_ornamental => 'Okrasno';

	/// sl: 'Drugo'
	String get type_other => 'Drugo';

	/// sl: 'Zgodovina opravil'
	String get history_title => 'Zgodovina opravil';

	/// sl: 'Na tem območju še ni opravil.'
	String get history_empty => 'Na tem območju še ni opravil.';

	/// sl: 'Uredi'
	String get action_edit => 'Uredi';

	/// sl: 'Izbriši'
	String get action_delete => 'Izbriši';

	/// sl: 'Izbriši območje?'
	String get delete_confirm_title => 'Izbriši območje?';

	/// sl: 'Opravila ostanejo, a izgubijo povezavo z območjem.'
	String get delete_confirm_body => 'Opravila ostanejo, a izgubijo povezavo z območjem.';

	/// sl: 'Novo območje'
	String get form_title_new => 'Novo območje';

	/// sl: 'Uredi območje'
	String get form_title_edit => 'Uredi območje';

	/// sl: 'Ime'
	String get form_name => 'Ime';

	/// sl: 'npr. Visoka greda 1'
	String get form_name_hint => 'npr. Visoka greda 1';

	/// sl: 'Tip'
	String get form_type => 'Tip';

	/// sl: 'Rastline v območju'
	String get form_plants => 'Rastline v območju';

	/// sl: '+ Dodaj rastlino'
	String get form_plants_add => '+ Dodaj rastlino';

	/// sl: 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.'
	String get form_plants_note => 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.';

	/// sl: 'Območja nimajo svoje lokacije — vsa so na tvoji posesti. Lokacija za vreme se nastavi enkrat v profilu.'
	String get form_location_info => 'Območja nimajo svoje lokacije — vsa so na tvoji posesti. Lokacija za vreme se nastavi enkrat v profilu.';

	/// sl: 'Shrani območje'
	String get form_save => 'Shrani območje';

	/// sl: 'Vnesi ime območja.'
	String get err_name => 'Vnesi ime območja.';

	/// sl: 'Še ni rastlin.'
	String get plants_empty => 'Še ni rastlin.';

	/// sl: 'Odstrani'
	String get plant_remove => 'Odstrani';
}

// Path: plants
class Translations$plants$sl {
	Translations$plants$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Izberi rastlino'
	String get picker_title => 'Izberi rastlino';

	/// sl: 'Išči rastlino…'
	String get search_hint => 'Išči rastlino…';

	/// sl: 'Vse'
	String get cat_all => 'Vse';

	/// sl: 'Sadno drevje'
	String get cat_fruit_tree => 'Sadno drevje';

	/// sl: 'Jagodičevje'
	String get cat_berries => 'Jagodičevje';

	/// sl: 'Zelenjava'
	String get cat_vegetable => 'Zelenjava';

	/// sl: 'Zelišča'
	String get cat_herbs => 'Zelišča';

	/// sl: 'Okrasne'
	String get cat_ornamental => 'Okrasne';

	/// sl: 'Trata'
	String get cat_lawn => 'Trata';

	/// sl: 'Iz baze'
	String get from_catalog => 'Iz baze';

	/// sl: 'Ne najdeš?'
	String get not_found => 'Ne najdeš?';

	/// sl: '+ Dodaj po meri: „$q“'
	String custom_add({required Object q}) => '+ Dodaj po meri: „${q}“';

	/// sl: 'Lasten vnos je zaseben in se ne deli s skupnostjo.'
	String get custom_private => 'Lasten vnos je zaseben in se ne deli s skupnostjo.';
}

// Path: supplies
class Translations$supplies$sl {
	Translations$supplies$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Zaloge'
	String get title => 'Zaloge';

	/// sl: 'kaj imam doma'
	String get subtitle => 'kaj imam doma';

	/// sl: 'Ni zalog. Dodaj jih z +.'
	String get empty => 'Ni zalog. Dodaj jih z +.';

	/// sl: 'malo'
	String get low => 'malo';

	/// sl: '~$q$unit'
	String qty({required Object q, required Object unit}) => '~${q}${unit}';

	/// sl: 'Novo sredstvo'
	String get form_new => 'Novo sredstvo';

	/// sl: 'Uredi sredstvo'
	String get form_edit => 'Uredi sredstvo';

	/// sl: 'Ime'
	String get form_name => 'Ime';

	/// sl: 'Količina'
	String get form_quantity => 'Količina';

	/// sl: 'Enota'
	String get form_unit => 'Enota';

	/// sl: 'Opozori pri (prag)'
	String get form_threshold => 'Opozori pri (prag)';

	/// sl: 'Shrani'
	String get form_save => 'Shrani';

	/// sl: 'Vnesi ime sredstva.'
	String get err_name => 'Vnesi ime sredstva.';

	/// sl: 'Dodaj sredstvo'
	String get add_to_task => 'Dodaj sredstvo';

	/// sl: 'Novo sredstvo'
	String get pick_new => 'Novo sredstvo';

	/// sl: 'Porabljena količina'
	String get amount => 'Porabljena količina';

	/// sl: 'Dodaj'
	String get add_confirm => 'Dodaj';
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
			'nav.areas' => 'Območja',
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
			'notes.title_new' => 'Nova opomba',
			'notes.title_edit' => 'Uredi opombo',
			'notes.content_label' => 'Zapis',
			'notes.content_hint' => 'Prosto besedilo — opažanje, ideja, misel…',
			'notes.when' => 'Kdaj',
			'notes.today' => 'Danes',
			'notes.yesterday' => 'Včeraj',
			'notes.pick_date' => 'Datum…',
			'notes.area' => 'Območje (neobvezno)',
			'notes.no_areas' => 'Ni območij — dodaj jih v razdelku Območja.',
			'notes.plant' => 'Rastlina (neobvezno)',
			'notes.save' => 'Shrani opombo',
			'notes.err_content' => 'Vpiši besedilo opombe.',
			'notes.delete' => 'Izbriši opombo',
			'notes.delete_confirm' => 'To dejanje je nepopravljivo.',
			'notes.info' => '🌧️ Vreme se shrani samodejno.',
			'task_detail.section_weather' => 'Vremenski posnetek',
			'task_detail.weather_placeholder' => 'Vremenski posnetek bo na voljo v M4.',
			'task_detail.section_details' => 'Podrobnosti',
			'task_detail.label_area' => 'Območje',
			'task_detail.label_plant' => 'Rastlina',
			'task_detail.label_supplies' => 'Sredstva',
			'task_detail.label_reminder' => 'Opomnik',
			'task_detail.label_recurrence' => 'Ponavljanje',
			'task_detail.label_note' => 'Opomba',
			'task_detail.badge_waiting' => 'Načrtovano',
			'task_detail.badge_done' => 'Opravljeno',
			'task_detail.action_complete' => '✓  Označi kot opravljeno',
			'task_detail.action_postpone' => '+1 dan',
			'task_detail.action_edit' => 'Uredi',
			'task_detail.action_duplicate' => 'Podvoji',
			'task_detail.action_delete' => 'Izbriši',
			'task_detail.action_revert' => 'Na čaka',
			'task_detail.action_move' => 'Premakni',
			'task_detail.recurrence_once' => 'Enkratno',
			'task_detail.recurrence_weekly' => 'Tedensko',
			'task_detail.recurrence_seasonal' => 'Sezonsko',
			'task_detail.none' => '—',
			'task_detail.not_found' => 'Opravilo ni bilo najdeno.',
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
			'task_form.plant_select' => 'Izberi rastlino',
			'task_form.plant_none' => 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.',
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
			'areas.title' => 'Območja',
			'areas.subtitle' => 'moja posest',
			'areas.empty' => 'Ni območij. Dodaj prvo z +.',
			'areas.last_prefix' => 'zadnje:',
			'areas.type_lawn' => 'Trata',
			'areas.type_hedge' => 'Živa meja',
			'areas.type_bed' => 'Gredica',
			'areas.type_tree' => 'Sadno drevje',
			'areas.type_ornamental' => 'Okrasno',
			'areas.type_other' => 'Drugo',
			'areas.history_title' => 'Zgodovina opravil',
			'areas.history_empty' => 'Na tem območju še ni opravil.',
			'areas.action_edit' => 'Uredi',
			'areas.action_delete' => 'Izbriši',
			'areas.delete_confirm_title' => 'Izbriši območje?',
			'areas.delete_confirm_body' => 'Opravila ostanejo, a izgubijo povezavo z območjem.',
			'areas.form_title_new' => 'Novo območje',
			'areas.form_title_edit' => 'Uredi območje',
			'areas.form_name' => 'Ime',
			'areas.form_name_hint' => 'npr. Visoka greda 1',
			'areas.form_type' => 'Tip',
			'areas.form_plants' => 'Rastline v območju',
			'areas.form_plants_add' => '+ Dodaj rastlino',
			'areas.form_plants_note' => 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.',
			'areas.form_location_info' => 'Območja nimajo svoje lokacije — vsa so na tvoji posesti. Lokacija za vreme se nastavi enkrat v profilu.',
			'areas.form_save' => 'Shrani območje',
			'areas.err_name' => 'Vnesi ime območja.',
			'areas.plants_empty' => 'Še ni rastlin.',
			'areas.plant_remove' => 'Odstrani',
			'plants.picker_title' => 'Izberi rastlino',
			'plants.search_hint' => 'Išči rastlino…',
			'plants.cat_all' => 'Vse',
			'plants.cat_fruit_tree' => 'Sadno drevje',
			'plants.cat_berries' => 'Jagodičevje',
			'plants.cat_vegetable' => 'Zelenjava',
			'plants.cat_herbs' => 'Zelišča',
			'plants.cat_ornamental' => 'Okrasne',
			'plants.cat_lawn' => 'Trata',
			'plants.from_catalog' => 'Iz baze',
			'plants.not_found' => 'Ne najdeš?',
			'plants.custom_add' => ({required Object q}) => '+ Dodaj po meri: „${q}“',
			'plants.custom_private' => 'Lasten vnos je zaseben in se ne deli s skupnostjo.',
			'supplies.title' => 'Zaloge',
			'supplies.subtitle' => 'kaj imam doma',
			'supplies.empty' => 'Ni zalog. Dodaj jih z +.',
			'supplies.low' => 'malo',
			'supplies.qty' => ({required Object q, required Object unit}) => '~${q}${unit}',
			'supplies.form_new' => 'Novo sredstvo',
			'supplies.form_edit' => 'Uredi sredstvo',
			'supplies.form_name' => 'Ime',
			'supplies.form_quantity' => 'Količina',
			'supplies.form_unit' => 'Enota',
			'supplies.form_threshold' => 'Opozori pri (prag)',
			'supplies.form_save' => 'Shrani',
			'supplies.err_name' => 'Vnesi ime sredstva.',
			'supplies.add_to_task' => 'Dodaj sredstvo',
			'supplies.pick_new' => 'Novo sredstvo',
			'supplies.amount' => 'Porabljena količina',
			'supplies.add_confirm' => 'Dodaj',
			_ => null,
		};
	}
}

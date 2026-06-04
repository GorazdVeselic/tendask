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
	late final Translations$notes$sl notes = Translations$notes$sl.internal(_root);
	late final Translations$task_detail$sl task_detail = Translations$task_detail$sl.internal(_root);
	late final Translations$tasks_list$sl tasks_list = Translations$tasks_list$sl.internal(_root);
	late final Translations$subject_picker$sl subject_picker = Translations$subject_picker$sl.internal(_root);
	late final Translations$entry$sl entry = Translations$entry$sl.internal(_root);
	late final Translations$plant_edit$sl plant_edit = Translations$plant_edit$sl.internal(_root);
	late final Translations$plant_detail$sl plant_detail = Translations$plant_detail$sl.internal(_root);
	late final Translations$areas$sl areas = Translations$areas$sl.internal(_root);
	late final Translations$plants$sl plants = Translations$plants$sl.internal(_root);
	late final Translations$supplies$sl supplies = Translations$supplies$sl.internal(_root);
	late final Translations$settings$sl settings = Translations$settings$sl.internal(_root);
	late final Translations$weather$sl weather = Translations$weather$sl.internal(_root);
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

	/// sl: 'Vrt'
	String get areas => 'Vrt';

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

	/// sl: '💡 Tapni na dan za pregled in dodajanje opravil.'
	String get month_hint => '💡 Tapni na dan za pregled in dodajanje opravil.';

	/// sl: '(one) {{n} opravilo ta mesec} (other) {{n} opravil ta mesec}'
	String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: '{n} opravilo ta mesec',
		other: '{n} opravil ta mesec',
	);

	/// sl: 'Ni opravil ta dan.'
	String get day_empty => 'Ni opravil ta dan.';

	/// sl: 'Dodaj opravilo na ta dan'
	String get day_add => 'Dodaj opravilo na ta dan';
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

	/// sl: 'Podrobnosti'
	String get section_details => 'Podrobnosti';

	/// sl: 'Območje'
	String get label_area => 'Območje';

	/// sl: 'Za kaj'
	String get label_subjects => 'Za kaj';

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

// Path: subject_picker
class Translations$subject_picker$sl {
	Translations$subject_picker$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Rastlina ali območje'
	String get title => 'Rastlina ali območje';

	/// sl: 'rastlina ali območje'
	String get hint => 'rastlina ali območje';

	/// sl: 'Išči rastlino ali območje…'
	String get search_hint => 'Išči rastlino ali območje…';

	/// sl: 'Rastline'
	String get section_plants => 'Rastline';

	/// sl: 'Območja'
	String get section_areas => 'Območja';

	/// sl: 'Dodaj iz kataloga'
	String get from_catalog => 'Dodaj iz kataloga';

	/// sl: 'Izberi'
	String get choose => 'Izberi';

	/// sl: 'Potrdi'
	String get confirm => 'Potrdi';

	/// sl: 'Izberi vsaj eno rastlino ali trato.'
	String get err_select => 'Izberi vsaj eno rastlino ali trato.';

	/// sl: 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.'
	String get empty => 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.';
}

// Path: entry
class Translations$entry$sl {
	Translations$entry$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Novo opravilo'
	String get title_new => 'Novo opravilo';

	/// sl: 'Pregled'
	String get title_review => 'Pregled';

	/// sl: 'Nadaljuj'
	String get kContinue => 'Nadaljuj';

	/// sl: 'Preskoči'
	String get skip => 'Preskoči';

	/// sl: 'Shrani opravilo'
	String get save => 'Shrani opravilo';

	/// sl: 'Korak'
	String get step => 'Korak';

	/// sl: 'Le zapis brez opravila?'
	String get note_card_title => 'Le zapis brez opravila?';

	/// sl: 'Opomba ›'
	String get note_card_action => 'Opomba ›';

	/// sl: 'Ponovi zadnje'
	String get repeat_last => 'Ponovi zadnje';

	/// sl: 'Kaj boš naredil?'
	String get type_title => 'Kaj boš naredil?';

	/// sl: 'Tap na opravilo te samodejno pelje naprej.'
	String get type_hint => 'Tap na opravilo te samodejno pelje naprej.';

	/// sl: 'Pokaži vse ($n)'
	String type_show_all({required Object n}) => 'Pokaži vse (${n})';

	/// sl: 'Pokaži manj'
	String get type_show_less => 'Pokaži manj';

	/// sl: 'Za kaj?'
	String get subject_title => 'Za kaj?';

	/// sl: 'Išči rastlino…'
	String get subject_search_hint => 'Išči rastlino…';

	/// sl: 'Rastline'
	String get subject_plants => 'Rastline';

	/// sl: 'Dodaj rastlino'
	String get subject_add_plant => 'Dodaj rastlino';

	/// sl: 'Dodaj območje'
	String get subject_add_area => 'Dodaj območje';

	/// sl: 'Dodaj iz kataloga'
	String get subject_from_catalog => 'Dodaj iz kataloga';

	/// sl: 'Območja:'
	String get subject_areas_context => 'Območja:';

	/// sl: 'Ali celotno območje'
	String get subject_area_section => 'Ali celotno območje';

	/// sl: '(npr. trata)'
	String get subject_area_hint => '(npr. trata)';

	/// sl: 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).'
	String get subject_area_note => 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).';

	/// sl: 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.'
	String get subject_empty => 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.';

	/// sl: 'Kdaj'
	String get when_title => 'Kdaj';

	/// sl: 'Danes'
	String get when_today => 'Danes';

	/// sl: 'Jutri'
	String get when_tomorrow => 'Jutri';

	/// sl: 'Datum…'
	String get when_pick_date => 'Datum…';

	/// sl: 'Datum'
	String get when_date => 'Datum';

	/// sl: 'Ura'
	String get when_time => 'Ura';

	/// sl: 'Privzeto: danes ob naslednji polni uri.'
	String get when_default_note => 'Privzeto: danes ob naslednji polni uri.';

	/// sl: 'Status'
	String get when_status => 'Status';

	/// sl: 'Čaka'
	String get when_status_waiting => 'Čaka';

	/// sl: 'Opravljeno'
	String get when_status_done => 'Opravljeno';

	/// sl: 'Privzeto izpeljano iz datuma in ure: v prihodnosti = čaka, sicer = opravljeno.'
	String get when_status_note => 'Privzeto izpeljano iz datuma in ure: v prihodnosti = čaka, sicer = opravljeno.';

	/// sl: 'Opomnik'
	String get reminder_title => 'Opomnik';

	/// sl: '(neobvezno)'
	String get optional => '(neobvezno)';

	/// sl: 'Ta korak je tu, ker je opravilo načrtovano (Čaka). Opomnik te ob izbranem času opozori na telefon.'
	String get reminder_why => 'Ta korak je tu, ker je opravilo načrtovano (Čaka). Opomnik te ob izbranem času opozori na telefon.';

	/// sl: 'Dodaj opomnik'
	String get reminder_add => 'Dodaj opomnik';

	/// sl: 'Nastavljiv zamik in ura. Več opomnikov na eno opravilo.'
	String get reminder_note => 'Nastavljiv zamik in ura. Več opomnikov na eno opravilo.';

	/// sl: 'Sredstva'
	String get supplies_title => 'Sredstva';

	/// sl: 'Ta korak je tu, ker opravilo običajno porabi sredstva. Odšteje se iz zaloge.'
	String get supplies_why => 'Ta korak je tu, ker opravilo običajno porabi sredstva. Odšteje se iz zaloge.';

	/// sl: 'Dodaj sredstvo iz zalog'
	String get supplies_add => 'Dodaj sredstvo iz zalog';

	/// sl: 'Ena mešanica za vse izbrane rastline — odšteje se enkrat.'
	String get supplies_note => 'Ena mešanica za vse izbrane rastline — odšteje se enkrat.';

	/// sl: 'Še preveri — tap na vrstico za popravek'
	String get review_title => 'Še preveri — tap na vrstico za popravek';

	/// sl: 'Opravilo'
	String get review_type => 'Opravilo';

	/// sl: 'Za kaj'
	String get review_subject => 'Za kaj';

	/// sl: 'Kdaj'
	String get review_when => 'Kdaj';

	/// sl: 'Opomnik'
	String get review_reminder => 'Opomnik';

	/// sl: 'Sredstva'
	String get review_supplies => 'Sredstva';

	/// sl: 'Popravi'
	String get review_fix => 'Popravi';

	/// sl: '—'
	String get review_none => '—';

	/// sl: 'Opomba'
	String get note_label => 'Opomba';

	/// sl: 'npr. zjutraj pred napovedanim dežjem'
	String get note_hint => 'npr. zjutraj pred napovedanim dežjem';

	/// sl: '🌧️ Vreme se shrani samodejno ob izvedbi.'
	String get weather_note => '🌧️ Vreme se shrani samodejno ob izvedbi.';

	/// sl: 'Izberi vsaj eno rastlino ali območje.'
	String get err_subject => 'Izberi vsaj eno rastlino ali območje.';

	/// sl: 'Ob dogodku'
	String get rem_event => 'Ob dogodku';

	/// sl: '10 minut prej'
	String get rem_10min => '10 minut prej';

	/// sl: '1 uro prej'
	String get rem_1hour => '1 uro prej';

	/// sl: '1 dan prej'
	String get rem_1day => '1 dan prej';

	/// sl: '2 dni prej'
	String get rem_2day => '2 dni prej';

	/// sl: 'ob $t'
	String rem_at({required Object t}) => 'ob ${t}';

	/// sl: 'Ob uri'
	String get rem_choose_time => 'Ob uri';

	/// sl: 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).'
	String get rem_time_note => 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).';
}

// Path: plant_edit
class Translations$plant_edit$sl {
	Translations$plant_edit$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Dodaj rastlino'
	String get title_new => 'Dodaj rastlino';

	/// sl: 'Uredi rastlino'
	String get title_edit => 'Uredi rastlino';

	/// sl: 'Vrsta'
	String get species => 'Vrsta';

	/// sl: 'Izberi vrsto'
	String get species_choose => 'Izberi vrsto';

	/// sl: 'Spremeni'
	String get species_change => 'Spremeni';

	/// sl: 'Osebno ime (neobvezno)'
	String get alias => 'Osebno ime (neobvezno)';

	/// sl: 'npr. „stara jablana ob ograji“'
	String get alias_hint => 'npr. „stara jablana ob ograji“';

	/// sl: 'Vidiš ga samo ti; prikaže se namesto privzetega imena.'
	String get alias_note => 'Vidiš ga samo ti; prikaže se namesto privzetega imena.';

	/// sl: 'Kje raste'
	String get locations => 'Kje raste';

	/// sl: 'izberi eno ali več območij'
	String get locations_hint => 'izberi eno ali več območij';

	/// sl: 'Brez območja je tudi v redu (npr. lončnica na terasi).'
	String get locations_note => 'Brez območja je tudi v redu (npr. lončnica na terasi).';

	/// sl: 'Novo območje'
	String get new_area => 'Novo območje';

	/// sl: 'Odstrani rastlino iz vrta'
	String get delete => 'Odstrani rastlino iz vrta';

	/// sl: 'Zgodovina opravil ostane v Dnevniku.'
	String get delete_note => 'Zgodovina opravil ostane v Dnevniku.';

	/// sl: 'Shrani'
	String get save => 'Shrani';

	/// sl: 'Najprej izberi vrsto rastline.'
	String get err_species => 'Najprej izberi vrsto rastline.';
}

// Path: plant_detail
class Translations$plant_detail$sl {
	Translations$plant_detail$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Rastlina ni bila najdena.'
	String get not_found => 'Rastlina ni bila najdena.';

	/// sl: 'Zgodovina opravil'
	String get history_title => 'Zgodovina opravil';

	/// sl: 'Za to rastlino še ni opravil.'
	String get history_empty => 'Za to rastlino še ni opravil.';
}

// Path: areas
class Translations$areas$sl {
	Translations$areas$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Vrt'
	String get title => 'Vrt';

	/// sl: 'rastline in trate'
	String get subtitle => 'rastline in trate';

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

	/// sl: 'Dodaj rastlino'
	String get form_plants_add => 'Dodaj rastlino';

	/// sl: 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.'
	String get form_plants_note => 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.';

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

	/// sl: 'Izberi rastlino'
	String get field_add => 'Izberi rastlino';

	/// sl: 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.'
	String get field_empty => 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.';
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

// Path: settings
class Translations$settings$sl {
	Translations$settings$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Nastavitve'
	String get title => 'Nastavitve';

	/// sl: 'Gost (brez prijave)'
	String get profile_guest => 'Gost (brez prijave)';

	/// sl: 'Lokacija'
	String get section_location => 'Lokacija';

	/// sl: 'Lokacija za vreme'
	String get location_placeholder => 'Lokacija za vreme';

	/// sl: 'Jezik'
	String get section_language => 'Jezik';

	/// sl: 'Obvestila'
	String get section_notifications => 'Obvestila';

	/// sl: 'Obvestila in opomniki'
	String get notifications_placeholder => 'Obvestila in opomniki';

	/// sl: 'Vrt'
	String get section_garden => 'Vrt';

	/// sl: '📦 Zaloge & sredstva'
	String get supplies => '📦 Zaloge & sredstva';

	/// sl: 'urea, alge, gnojila, oprema'
	String get supplies_sub => 'urea, alge, gnojila, oprema';

	/// sl: '🪴 Območja'
	String get areas => '🪴 Območja';

	/// sl: 'trate, meje, gredice'
	String get areas_sub => 'trate, meje, gredice';

	/// sl: 'Račun & podatki'
	String get section_account => 'Račun & podatki';

	/// sl: 'Enote'
	String get units => 'Enote';

	/// sl: 'Izvozi podatke (GDPR)'
	String get export_data => 'Izvozi podatke (GDPR)';

	/// sl: 'Odjava'
	String get logout => 'Odjava';

	/// sl: 'Izbriši račun in vse podatke'
	String get delete_account => 'Izbriši račun in vse podatke';

	/// sl: 'Na voljo kmalu'
	String get coming_soon => 'Na voljo kmalu';

	/// sl: 'Tendask · v1 (MVP)'
	String get version => 'Tendask · v1 (MVP)';
}

// Path: weather
class Translations$weather$sl {
	Translations$weather$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Jasno'
	String get cond_clear => 'Jasno';

	/// sl: 'Pretežno jasno'
	String get cond_mainly_clear => 'Pretežno jasno';

	/// sl: 'Oblačno'
	String get cond_cloudy => 'Oblačno';

	/// sl: 'Megla'
	String get cond_fog => 'Megla';

	/// sl: 'Rosenje'
	String get cond_drizzle => 'Rosenje';

	/// sl: 'Dež'
	String get cond_rain => 'Dež';

	/// sl: 'Sneg'
	String get cond_snow => 'Sneg';

	/// sl: 'Plohe'
	String get cond_showers => 'Plohe';

	/// sl: 'Nevihta'
	String get cond_thunderstorm => 'Nevihta';

	/// sl: '—'
	String get cond_unknown => '—';

	/// sl: 'Napoved'
	String get band_forecast => 'Napoved';

	/// sl: 'Dež zadnjih 48 h:'
	String get rain_past48h => 'Dež zadnjih 48 h:';

	/// sl: 'Vreme bo zabeleženo, ko označiš opravilo kot opravljeno.'
	String get detail_waiting => 'Vreme bo zabeleženo, ko označiš opravilo kot opravljeno.';

	/// sl: 'Vremenski posnetek ni na voljo (zajet brez povezave).'
	String get detail_none => 'Vremenski posnetek ni na voljo (zajet brez povezave).';

	/// sl: 'Vreme trenutno ni na voljo.'
	String get home_unavailable => 'Vreme trenutno ni na voljo.';
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
			'nav.areas' => 'Vrt',
			'nav.tasks' => 'Opravila',
			'home.greeting' => 'Dober dan 🌿',
			'home.today' => 'Danes',
			'home.recent' => 'Nazadnje',
			'home.no_tasks_today' => 'Danes ni načrtovanih opravil.',
			'home.no_recent' => 'Še ni opravljenih opravil.',
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
			'journal.month_hint' => '💡 Tapni na dan za pregled in dodajanje opravil.',
			'journal.month_count' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n, one: '{n} opravilo ta mesec', other: '{n} opravil ta mesec', ), 
			'journal.day_empty' => 'Ni opravil ta dan.',
			'journal.day_add' => 'Dodaj opravilo na ta dan',
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
			'task_detail.section_details' => 'Podrobnosti',
			'task_detail.label_area' => 'Območje',
			'task_detail.label_subjects' => 'Za kaj',
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
			'subject_picker.title' => 'Rastlina ali območje',
			'subject_picker.hint' => 'rastlina ali območje',
			'subject_picker.search_hint' => 'Išči rastlino ali območje…',
			'subject_picker.section_plants' => 'Rastline',
			'subject_picker.section_areas' => 'Območja',
			'subject_picker.from_catalog' => 'Dodaj iz kataloga',
			'subject_picker.choose' => 'Izberi',
			'subject_picker.confirm' => 'Potrdi',
			'subject_picker.err_select' => 'Izberi vsaj eno rastlino ali trato.',
			'subject_picker.empty' => 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.',
			'entry.title_new' => 'Novo opravilo',
			'entry.title_review' => 'Pregled',
			'entry.kContinue' => 'Nadaljuj',
			'entry.skip' => 'Preskoči',
			'entry.save' => 'Shrani opravilo',
			'entry.step' => 'Korak',
			'entry.note_card_title' => 'Le zapis brez opravila?',
			'entry.note_card_action' => 'Opomba ›',
			'entry.repeat_last' => 'Ponovi zadnje',
			'entry.type_title' => 'Kaj boš naredil?',
			'entry.type_hint' => 'Tap na opravilo te samodejno pelje naprej.',
			'entry.type_show_all' => ({required Object n}) => 'Pokaži vse (${n})',
			'entry.type_show_less' => 'Pokaži manj',
			'entry.subject_title' => 'Za kaj?',
			'entry.subject_search_hint' => 'Išči rastlino…',
			'entry.subject_plants' => 'Rastline',
			'entry.subject_add_plant' => 'Dodaj rastlino',
			'entry.subject_add_area' => 'Dodaj območje',
			'entry.subject_from_catalog' => 'Dodaj iz kataloga',
			'entry.subject_areas_context' => 'Območja:',
			'entry.subject_area_section' => 'Ali celotno območje',
			'entry.subject_area_hint' => '(npr. trata)',
			'entry.subject_area_note' => 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).',
			'entry.subject_empty' => 'Ni rastlin ali območij. Dodaj jih v zavihku Vrt.',
			'entry.when_title' => 'Kdaj',
			'entry.when_today' => 'Danes',
			'entry.when_tomorrow' => 'Jutri',
			'entry.when_pick_date' => 'Datum…',
			'entry.when_date' => 'Datum',
			'entry.when_time' => 'Ura',
			'entry.when_default_note' => 'Privzeto: danes ob naslednji polni uri.',
			'entry.when_status' => 'Status',
			'entry.when_status_waiting' => 'Čaka',
			'entry.when_status_done' => 'Opravljeno',
			'entry.when_status_note' => 'Privzeto izpeljano iz datuma in ure: v prihodnosti = čaka, sicer = opravljeno.',
			'entry.reminder_title' => 'Opomnik',
			'entry.optional' => '(neobvezno)',
			'entry.reminder_why' => 'Ta korak je tu, ker je opravilo načrtovano (Čaka). Opomnik te ob izbranem času opozori na telefon.',
			'entry.reminder_add' => 'Dodaj opomnik',
			'entry.reminder_note' => 'Nastavljiv zamik in ura. Več opomnikov na eno opravilo.',
			'entry.supplies_title' => 'Sredstva',
			'entry.supplies_why' => 'Ta korak je tu, ker opravilo običajno porabi sredstva. Odšteje se iz zaloge.',
			'entry.supplies_add' => 'Dodaj sredstvo iz zalog',
			'entry.supplies_note' => 'Ena mešanica za vse izbrane rastline — odšteje se enkrat.',
			'entry.review_title' => 'Še preveri — tap na vrstico za popravek',
			'entry.review_type' => 'Opravilo',
			'entry.review_subject' => 'Za kaj',
			'entry.review_when' => 'Kdaj',
			'entry.review_reminder' => 'Opomnik',
			'entry.review_supplies' => 'Sredstva',
			'entry.review_fix' => 'Popravi',
			'entry.review_none' => '—',
			'entry.note_label' => 'Opomba',
			'entry.note_hint' => 'npr. zjutraj pred napovedanim dežjem',
			'entry.weather_note' => '🌧️ Vreme se shrani samodejno ob izvedbi.',
			'entry.err_subject' => 'Izberi vsaj eno rastlino ali območje.',
			'entry.rem_event' => 'Ob dogodku',
			'entry.rem_10min' => '10 minut prej',
			'entry.rem_1hour' => '1 uro prej',
			'entry.rem_1day' => '1 dan prej',
			'entry.rem_2day' => '2 dni prej',
			'entry.rem_at' => ({required Object t}) => 'ob ${t}',
			'entry.rem_choose_time' => 'Ob uri',
			'entry.rem_time_note' => 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).',
			'plant_edit.title_new' => 'Dodaj rastlino',
			'plant_edit.title_edit' => 'Uredi rastlino',
			'plant_edit.species' => 'Vrsta',
			'plant_edit.species_choose' => 'Izberi vrsto',
			'plant_edit.species_change' => 'Spremeni',
			'plant_edit.alias' => 'Osebno ime (neobvezno)',
			'plant_edit.alias_hint' => 'npr. „stara jablana ob ograji“',
			'plant_edit.alias_note' => 'Vidiš ga samo ti; prikaže se namesto privzetega imena.',
			'plant_edit.locations' => 'Kje raste',
			'plant_edit.locations_hint' => 'izberi eno ali več območij',
			'plant_edit.locations_note' => 'Brez območja je tudi v redu (npr. lončnica na terasi).',
			'plant_edit.new_area' => 'Novo območje',
			'plant_edit.delete' => 'Odstrani rastlino iz vrta',
			'plant_edit.delete_note' => 'Zgodovina opravil ostane v Dnevniku.',
			'plant_edit.save' => 'Shrani',
			'plant_edit.err_species' => 'Najprej izberi vrsto rastline.',
			'plant_detail.not_found' => 'Rastlina ni bila najdena.',
			'plant_detail.history_title' => 'Zgodovina opravil',
			'plant_detail.history_empty' => 'Za to rastlino še ni opravil.',
			'areas.title' => 'Vrt',
			'areas.subtitle' => 'rastline in trate',
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
			'areas.form_plants_add' => 'Dodaj rastlino',
			'areas.form_plants_note' => 'Opravila (obrez, tretiranje, pobiranje) se vežejo na izbrano rastlino.',
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
			'plants.field_add' => 'Izberi rastlino',
			'plants.field_empty' => 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.',
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
			'settings.title' => 'Nastavitve',
			'settings.profile_guest' => 'Gost (brez prijave)',
			'settings.section_location' => 'Lokacija',
			'settings.location_placeholder' => 'Lokacija za vreme',
			'settings.section_language' => 'Jezik',
			'settings.section_notifications' => 'Obvestila',
			'settings.notifications_placeholder' => 'Obvestila in opomniki',
			'settings.section_garden' => 'Vrt',
			'settings.supplies' => '📦 Zaloge & sredstva',
			'settings.supplies_sub' => 'urea, alge, gnojila, oprema',
			'settings.areas' => '🪴 Območja',
			'settings.areas_sub' => 'trate, meje, gredice',
			'settings.section_account' => 'Račun & podatki',
			'settings.units' => 'Enote',
			'settings.export_data' => 'Izvozi podatke (GDPR)',
			'settings.logout' => 'Odjava',
			'settings.delete_account' => 'Izbriši račun in vse podatke',
			'settings.coming_soon' => 'Na voljo kmalu',
			'settings.version' => 'Tendask · v1 (MVP)',
			'weather.cond_clear' => 'Jasno',
			'weather.cond_mainly_clear' => 'Pretežno jasno',
			'weather.cond_cloudy' => 'Oblačno',
			'weather.cond_fog' => 'Megla',
			'weather.cond_drizzle' => 'Rosenje',
			'weather.cond_rain' => 'Dež',
			'weather.cond_snow' => 'Sneg',
			'weather.cond_showers' => 'Plohe',
			'weather.cond_thunderstorm' => 'Nevihta',
			'weather.cond_unknown' => '—',
			'weather.band_forecast' => 'Napoved',
			'weather.rain_past48h' => 'Dež zadnjih 48 h:',
			'weather.detail_waiting' => 'Vreme bo zabeleženo, ko označiš opravilo kot opravljeno.',
			'weather.detail_none' => 'Vremenski posnetek ni na voljo (zajet brez povezave).',
			'weather.home_unavailable' => 'Vreme trenutno ni na voljo.',
			_ => null,
		};
	}
}

///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsSl extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsSl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.sl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <sl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsSl _root = this; // ignore: unused_field

	@override 
	TranslationsSl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsSl(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$splash$sl splash = _Translations$splash$sl._(_root);
	@override late final _Translations$nav$sl nav = _Translations$nav$sl._(_root);
	@override late final _Translations$home$sl home = _Translations$home$sl._(_root);
	@override late final _Translations$common$sl common = _Translations$common$sl._(_root);
	@override late final _Translations$swipe$sl swipe = _Translations$swipe$sl._(_root);
	@override late final _Translations$notifications$sl notifications = _Translations$notifications$sl._(_root);
	@override late final _Translations$notif_priming$sl notif_priming = _Translations$notif_priming$sl._(_root);
	@override late final _Translations$notif_settings$sl notif_settings = _Translations$notif_settings$sl._(_root);
	@override late final _Translations$notif_preview$sl notif_preview = _Translations$notif_preview$sl._(_root);
	@override late final _Translations$onboarding$sl onboarding = _Translations$onboarding$sl._(_root);
	@override late final _Translations$auth$sl auth = _Translations$auth$sl._(_root);
	@override late final _Translations$email_login$sl email_login = _Translations$email_login$sl._(_root);
	@override late final _Translations$location$sl location = _Translations$location$sl._(_root);
	@override late final _Translations$journal$sl journal = _Translations$journal$sl._(_root);
	@override late final _Translations$notes$sl notes = _Translations$notes$sl._(_root);
	@override late final _Translations$task_detail$sl task_detail = _Translations$task_detail$sl._(_root);
	@override late final _Translations$tasks_list$sl tasks_list = _Translations$tasks_list$sl._(_root);
	@override late final _Translations$subject_picker$sl subject_picker = _Translations$subject_picker$sl._(_root);
	@override late final _Translations$entry$sl entry = _Translations$entry$sl._(_root);
	@override late final _Translations$plant_edit$sl plant_edit = _Translations$plant_edit$sl._(_root);
	@override late final _Translations$plant_detail$sl plant_detail = _Translations$plant_detail$sl._(_root);
	@override late final _Translations$area_pick$sl area_pick = _Translations$area_pick$sl._(_root);
	@override late final _Translations$areas$sl areas = _Translations$areas$sl._(_root);
	@override late final _Translations$plants$sl plants = _Translations$plants$sl._(_root);
	@override late final _Translations$supplies$sl supplies = _Translations$supplies$sl._(_root);
	@override late final _Translations$settings$sl settings = _Translations$settings$sl._(_root);
	@override late final _Translations$weather$sl weather = _Translations$weather$sl._(_root);
}

// Path: splash
class _Translations$splash$sl extends Translations$splash$en {
	_Translations$splash$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Tvoj vrtni dnevnik 🌿';
}

// Path: nav
class _Translations$nav$sl extends Translations$nav$en {
	_Translations$nav$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get home => 'Domov';
	@override String get journal => 'Dnevnik';
	@override String get areas => 'Vrt';
	@override String get tasks => 'Opravila';
}

// Path: home
class _Translations$home$sl extends Translations$home$en {
	_Translations$home$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Dober dan 🌿';
	@override String get today => 'Danes';
	@override String get recent => 'Nazadnje';
	@override String get no_tasks_today => 'Danes ni načrtovanih opravil.';
	@override String get no_recent => 'Še ni opravljenih opravil.';
	@override String overdue_banner({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: '1 zamujeno opravilo',
		two: '${n} zamujeni opravili',
		few: '${n} zamujena opravila',
		other: '${n} zamujenih opravil',
	);
}

// Path: common
class _Translations$common$sl extends Translations$common$en {
	_Translations$common$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get today => 'Danes';
	@override String get yesterday => 'včeraj';
	@override String get load_error => 'Podatkov ni bilo mogoče naložiti.';
}

// Path: swipe
class _Translations$swipe$sl extends Translations$swipe$en {
	_Translations$swipe$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get complete => 'Opravljeno';
	@override String get postpone => '+1 dan';
	@override String get revert => 'Povrni';
	@override String get edit => 'Uredi';
	@override String get move => 'Premakni';
	@override String get delete => 'Izbriši';
}

// Path: notifications
class _Translations$notifications$sl extends Translations$notifications$en {
	_Translations$notifications$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get today => 'Danes';
	@override String get tomorrow => 'Jutri';
}

// Path: notif_priming
class _Translations$notif_priming$sl extends Translations$notif_priming$en {
	_Translations$notif_priming$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Naj te pravočasno opozorim?';
	@override String get why => 'Da ti opravilo ne uide — opomnik pride takrat, ko si ga nastavil.';
	@override String get benefit_reminders => 'Opomniki opravil — npr. »1 dan prej ob 18:00«.';
	@override String get benefit_weather => 'Pametni namig vremena — »jutri suho, primeren čas«. (neobvezno)';
	@override String get benefit_nearby => 'Namigi okolice — kaj počnejo drugi v tvoji bližini. (V2, neobvezno)';
	@override String get privacy => 'Vsako vrsto lahko ločeno vklopiš ali izklopiš, nastaviš tihe ure in omejiš pogostost. Brez zasipavanja.';
	@override String get enable => 'Vklopi obvestila';
	@override String get later => 'Mogoče kasneje';
}

// Path: notif_settings
class _Translations$notif_settings$sl extends Translations$notif_settings$en {
	_Translations$notif_settings$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Obvestila';
	@override String get load_error => 'Nastavitev ni bilo mogoče naložiti.';
	@override String get section_types => 'Vrste obvestil';
	@override String get type_reminders => 'Opomniki opravil';
	@override String get type_reminders_sub => 'lokalno · delujejo brez interneta';
	@override String get type_weather => 'Pametni namigi (vreme)';
	@override String get type_weather_sub => 'kmalu · prek strežnika';
	@override String get type_community => 'Namigi okolice';
	@override String get type_community_sub => 'kmalu (V2)';
	@override String get section_default_offset => 'Privzeti zamik opomnika';
	@override String get default_offset_hint => 'Predizpolni nova opravila; vedno lahko spremeniš.';
	@override String get section_quiet => 'Da te ne zasipa';
	@override String get quiet_hours => 'Tihe ure';
	@override String quiet_hours_sub({required Object range}) => '${range} brez obvestil';
	@override String get frequency_cap => 'Največ 1 namig na dan';
	@override String get frequency_cap_sub => 'vreme in okolico združimo v en povzetek';
	@override String get section_more => 'Več';
	@override String get preview => 'Predogled obvestil';
	@override String get preview_sub => 'kako izgledajo na zaklenjenem zaslonu';
	@override String get system_permission => 'Sistemsko dovoljenje';
	@override String get system_permission_on => 'naprava: dovoljeno';
	@override String get system_permission_off => 'točni opomniki niso dovoljeni — tapni za nastavitve';
}

// Path: notif_preview
class _Translations$notif_preview$sl extends Translations$notif_preview$en {
	_Translations$notif_preview$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Videz obvestil';
	@override String get date => 'torek, 1. junij';
	@override String get rem_now => 'zdaj';
	@override String get rem_title => '⏰ Foliarno škropljenje · 07:00';
	@override String get rem_body => 'Živa meja + trata · jutro je suho — primeren čas.';
	@override String get rem_tag => 'opomnik opravila';
	@override String get wx_title => 'Jutri zjutraj bo suho ☀️';
	@override String get wx_body => 'Primeren čas za foliarno škropljenje lovorikovcev.';
	@override String get wx_tag => 'pametni namig · vreme';
	@override String get com_yesterday => 'včeraj';
	@override String get com_title => 'Tvoja okolica';
	@override String get com_body => '68 % vrtnarjev v tvoji okolici je ta teden prvič pognojilo trato.';
	@override String get com_tag => 'namig okolice · V2';
	@override String get footer => 'Tap na obvestilo odpre ustrezni zaslon (opravilo · namig · okolica).';
}

// Path: onboarding
class _Translations$onboarding$sl extends Translations$onboarding$en {
	_Translations$onboarding$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Preskoči ›';
	@override String get next => 'Naprej';
	@override String get start => 'Začni 🌿';
	@override String get soon_badge => 'kmalu (V2)';
	@override String get welcome_title => 'Dobrodošel v Tendask';
	@override String get welcome_body => 'Tvoj preprost dnevnik za vrt, trato in živo mejo — vsa opravila na enem mestu.';
	@override String get log_title => 'Beleži v sekundi';
	@override String get log_body => 'Pokosil, zalil, pognojil? Zabeleži kaj, kdaj in kje — z nekaj dotiki. Vreme se shrani samodejno.';
	@override String get remind_title => 'Opomniki + vreme';
	@override String get remind_body => 'Načrtuj opravila, prejmi opomnik na telefon in vremenski namig — »jutri zjutraj bo suho, primeren čas za škropljenje«.';
	@override String get nearby_title => 'Tvoja okolica';
	@override String get nearby_body => 'Pozneje poglej, kaj počnejo vrtnarji v podobnem podnebju blizu tebe — anonimno in zasebno.';
}

// Path: auth
class _Translations$auth$sl extends Translations$auth$en {
	_Translations$auth$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dobrodošel v Tendask';
	@override String get value_prop => 'Shrani svoj vrtni dnevnik in ne izgubi zgodovine ob menjavi telefona.';
	@override String get continue_apple => 'Nadaljuj z Apple';
	@override String get continue_google => 'Nadaljuj z Google';
	@override String get continue_email => 'Nadaljuj z e-pošto';
	@override String get guest => 'Preizkusi brez računa';
	@override String get legal => 'Z e-pošto pošljemo potrditveno kodo (brez gesla). Nadaljevanje pomeni strinjanje s pogoji in zasebnostjo.';
	@override String get guest_warning => 'Brez računa se ob odstranitvi aplikacije ali menjavi naprave vsi podatki izgubijo.';
	@override String get google_error => 'Prijava z Google ni uspela. Poskusi znova.';
	@override String get coming_soon => 'Na voljo kmalu.';
	@override String get privacy_link => 'Politika zasebnosti';
}

// Path: email_login
class _Translations$email_login$sl extends Translations$email_login$en {
	_Translations$email_login$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prijava z e-pošto';
	@override String get email_label => 'E-poštni naslov';
	@override String get email_hint => 'ti@primer.si';
	@override String get send_code => 'Pošlji kodo';
	@override String get intro => 'Poslali ti bomo enkratno kodo — brez gesla.';
	@override String get code_label => 'Koda iz e-pošte';
	@override String get code_hint => 'Vnesi prejeto kodo';
	@override String code_sent({required Object email}) => 'Kodo smo poslali na ${email}. Vpiši jo spodaj.';
	@override String get verify => 'Potrdi in se prijavi';
	@override String get resend => 'Pošlji novo kodo';
	@override String get err_email => 'Vpiši veljaven e-poštni naslov.';
	@override String get err_code => 'Vpiši kodo iz e-pošte.';
	@override String get err_send => 'Kode ni bilo mogoče poslati. Preveri povezavo in poskusi znova.';
	@override String get err_verify => 'Koda ni pravilna ali je potekla. Poskusi znova.';
}

// Path: location
class _Translations$location$sl extends Translations$location$en {
	_Translations$location$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kje vrtnariš?';
	@override String get why => 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.';
	@override String get use_gps => 'Uporabi mojo lokacijo';
	@override String get or_enter => 'ali vpiši kraj';
	@override String get place_hint => 'Vas, mesto ali naslov (npr. Šentjur)';
	@override String get place_note => 'Dovolj je vas ali mesto — natančen naslov ni potreben.';
	@override String get search => 'Poišči';
	@override String get privacy => 'Tvojo lokacijo uporabimo le za približno določitev tvoje okolice (širše območje nekaj kilometrov). Natančna lokacija je shranjena le na tvoji napravi — pri nas hranimo samo okvirno okolico in je nikoli ne razkrijemo drugim.';
	@override String get kContinue => 'Nadaljuj';
	@override String get set_gps => 'Lokacija je nastavljena.';
	@override String set_place({required Object name}) => 'Lokacija: ${name}';
	@override String get err_denied => 'Dostop do lokacije je zavrnjen. Vpiši kraj ali omogoči dovoljenje v sistemskih nastavitvah.';
	@override String get err_disabled => 'Lokacijske storitve so izklopljene. Vklopi jih ali vpiši kraj.';
	@override String get err_unavailable => 'Lokacije ni bilo mogoče določiti. Poskusi znova ali vpiši kraj.';
	@override String get err_search => 'Iskanja ni bilo mogoče izvesti. Preveri povezavo in poskusi znova.';
	@override String get no_results => 'Za ta kraj ni zadetkov.';
	@override String get screen_title => 'Lokacija vrta';
	@override String get status_set => 'Lokacija je nastavljena';
	@override String get status_unset => 'Lokacija še ni nastavljena';
	@override String get clear => 'Odstrani lokacijo';
	@override String get clear_confirm_title => 'Odstranim lokacijo?';
	@override String get clear_confirm_body => 'Vreme bo prikazano za privzeto območje, dokler ne nastaviš nove lokacije.';
	@override String get clear_confirm_yes => 'Odstrani';
	@override String get clear_confirm_cancel => 'Prekliči';
	@override String get cleared => 'Lokacija odstranjena';
}

// Path: journal
class _Translations$journal$sl extends Translations$journal$en {
	_Translations$journal$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dnevnik';
	@override String get subtitle => 'vrtni dnevnik';
	@override String get filter_all => 'Vse';
	@override String get filter_tasks => '✓ Opravila';
	@override String get filter_notes => '✍️ Opombe';
	@override String get empty => 'Ni vnosov v dnevniku.';
	@override String get empty_tasks => 'Ni opravljenih opravil.';
	@override String get empty_notes => 'Ni opomb.';
	@override String get timeline => 'Časovnica';
	@override String get month_view => 'Mesec';
	@override String get month_hint => '💡 Tapni na dan za pregled in dodajanje opravil.';
	@override String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: '${n} opravilo ta mesec',
		two: '${n} opravili ta mesec',
		few: '${n} opravila ta mesec',
		other: '${n} opravil ta mesec',
	);
	@override String get day_empty => 'Ni opravil ta dan.';
	@override String get day_add => 'Dodaj opravilo na ta dan';
}

// Path: notes
class _Translations$notes$sl extends Translations$notes$en {
	_Translations$notes$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Nova opomba';
	@override String get title_edit => 'Uredi opombo';
	@override String get content_label => 'Zapis';
	@override String get content_hint => 'Prosto besedilo — opažanje, ideja, misel…';
	@override String get when => 'Kdaj';
	@override String get today => 'Danes';
	@override String get yesterday => 'Včeraj';
	@override String get pick_date => 'Datum…';
	@override String get area => 'Območje (neobvezno)';
	@override String get no_areas => 'Ni območij — dodaj jih v razdelku Območja.';
	@override String get plant => 'Rastlina (neobvezno)';
	@override String get save => 'Shrani opombo';
	@override String get err_content => 'Vpiši besedilo opombe.';
	@override String get delete => 'Izbriši opombo';
	@override String get delete_confirm => 'To dejanje je nepopravljivo.';
	@override String get info => '🌧️ Vreme se shrani samodejno.';
}

// Path: task_detail
class _Translations$task_detail$sl extends Translations$task_detail$en {
	_Translations$task_detail$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get section_weather => 'Vremenski posnetek';
	@override String get section_details => 'Podrobnosti';
	@override String get label_supplies => 'Sredstva';
	@override String get label_reminder => 'Opomnik';
	@override String get label_recurrence => 'Ponavljanje';
	@override String get label_note => 'Opomba';
	@override String get badge_waiting => 'Načrtovano';
	@override String get badge_done => 'Opravljeno';
	@override String get action_complete => '✓  Označi kot opravljeno';
	@override String get action_postpone => '+1 dan';
	@override String get action_edit => 'Uredi';
	@override String get action_duplicate => 'Podvoji';
	@override String get action_delete => 'Izbriši';
	@override String get action_revert => 'Na čaka';
	@override String get action_move => 'Premakni';
	@override String get recurrence_once => 'Enkratno';
	@override String get recurrence_weekly => 'Tedensko';
	@override String get recurrence_seasonal => 'Sezonsko';
	@override String get none => '—';
	@override String get not_found => 'Opravilo ni bilo najdeno.';
}

// Path: tasks_list
class _Translations$tasks_list$sl extends Translations$tasks_list$en {
	_Translations$tasks_list$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Opravila';
	@override String get subtitle => 'prihajajoča in zapadla';
	@override String get section_overdue => 'Zamuda';
	@override String get section_today => 'Danes';
	@override String get section_tomorrow => 'Jutri';
	@override String get section_this_week => 'Ta teden';
	@override String get section_later => 'Pozneje';
	@override String get empty => 'Ni čakajočih opravil. Dodaj novo z +.';
	@override String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: 'zamuja 1 dan',
		two: 'zamuja ${n} dni',
		few: 'zamuja ${n} dni',
		other: 'zamuja ${n} dni',
	);
	@override String get status_today => 'danes';
	@override String get status_tomorrow => 'jutri';
	@override String get action_complete => 'Opravljeno';
	@override String get action_postpone => '+1 dan';
	@override String get action_edit => 'Uredi';
	@override String get action_duplicate => 'Podvoji';
	@override String get action_delete => 'Izbriši';
	@override String get delete_confirm_title => 'Izbriši opravilo?';
	@override String get delete_confirm_body => 'To dejanje je nepopravljivo.';
	@override String get delete_yes => 'Izbriši';
	@override String get delete_cancel => 'Prekliči';
}

// Path: subject_picker
class _Translations$subject_picker$sl extends Translations$subject_picker$en {
	_Translations$subject_picker$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rastlina ali območje';
	@override String get choose => 'Izberi';
}

// Path: entry
class _Translations$entry$sl extends Translations$entry$en {
	_Translations$entry$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Novo opravilo';
	@override String get title_review => 'Pregled';
	@override String get kContinue => 'Nadaljuj';
	@override String get skip => 'Preskoči';
	@override String get save => 'Shrani opravilo';
	@override String get step => 'Korak';
	@override String get note_card_title => 'Le zapis brez opravila?';
	@override String get note_card_action => 'Opomba ›';
	@override String get repeat_last => 'Ponovi zadnje';
	@override String get type_title => 'Katero opravilo?';
	@override String get type_hint => 'Tap na opravilo te samodejno pelje naprej.';
	@override String type_show_all({required Object n}) => 'Pokaži vse (${n})';
	@override String get type_show_less => 'Pokaži manj';
	@override String get subject_title => 'Za kaj?';
	@override String get subject_search_hint => 'Išči rastlino…';
	@override String get subject_plants => 'Rastline';
	@override String get subject_add_plant => 'Dodaj rastlino';
	@override String get subject_add_area => 'Dodaj območje';
	@override String get subject_from_catalog => 'Dodaj iz kataloga';
	@override String get subject_areas_context => 'Območja:';
	@override String get subject_area_section => 'Ali celotno območje';
	@override String get subject_area_note => 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).';
	@override String get when_title => 'Kdaj';
	@override String get when_today => 'Danes';
	@override String get when_tomorrow => 'Jutri';
	@override String get when_pick_date => 'Datum…';
	@override String get when_date => 'Datum';
	@override String get when_time => 'Ura';
	@override String get when_default_note => 'Privzeto: danes ob naslednji polni uri.';
	@override String get when_status => 'Status';
	@override String get when_status_waiting => 'Čaka';
	@override String get when_status_done => 'Opravljeno';
	@override String get when_status_note => 'Privzeto izpeljano iz datuma in ure: v prihodnosti = čaka, sicer = opravljeno.';
	@override String get reminder_title => 'Opomnik';
	@override String get optional => '(neobvezno)';
	@override String get reminder_why => 'Ta korak je tu, ker je opravilo načrtovano (Čaka). Opomnik te ob izbranem času opozori na telefon.';
	@override String get reminder_add => 'Dodaj opomnik';
	@override String get reminder_note => 'Nastavljiv zamik in ura. Več opomnikov na eno opravilo.';
	@override String get supplies_title => 'Sredstva';
	@override String get supplies_why => 'Ta korak je tu, ker opravilo običajno porabi sredstva. Odšteje se iz zaloge.';
	@override String get supplies_add => 'Dodaj sredstvo iz zalog';
	@override String get supplies_note => 'Ena mešanica za vse izbrane rastline — odšteje se enkrat.';
	@override String get review_title => 'Še preveri — tap na vrstico za popravek';
	@override String get review_type => 'Opravilo';
	@override String get review_subject => 'Za kaj';
	@override String get review_when => 'Kdaj';
	@override String get review_reminder => 'Opomnik';
	@override String get review_supplies => 'Sredstva';
	@override String get review_fix => 'Popravi';
	@override String get review_none => '—';
	@override String get note_label => 'Opomba';
	@override String get note_hint => 'npr. zjutraj pred napovedanim dežjem';
	@override String get weather_note => '🌧️ Vreme se shrani samodejno ob izvedbi.';
	@override String get err_subject => 'Izberi vsaj eno rastlino ali območje.';
	@override String get rem_event => 'Ob dogodku';
	@override String get rem_10min => '10 minut prej';
	@override String get rem_1hour => '1 uro prej';
	@override String get rem_1day => '1 dan prej';
	@override String get rem_2day => '2 dni prej';
	@override String get rem_custom => 'Po meri…';
	@override String get rem_unit_min => 'min';
	@override String get rem_unit_hour => 'ure';
	@override String get rem_unit_day => 'dni';
	@override String get rem_custom_label => 'Koliko prej naj opozorim?';
	@override String get rem_before => 'prej';
	@override String rem_at({required Object t}) => 'ob ${t}';
	@override String get rem_choose_time => 'Ob uri';
	@override String get rem_time_note => 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).';
	@override String get rem_perm_denied => 'Obvestila so onemogočena, zato opomnika ni mogoče dodati.';
	@override String get rem_exact_title => 'Dovoli točne opomnike';
	@override String get rem_exact_body => 'Za sprožitev ob točnem času Tendask potrebuje dovoljenje »Budilke in opomniki«. Vklopi ga v nastavitvah, nato znova dodaj opomnik.';
	@override String get rem_exact_open => 'Odpri nastavitve';
	@override String get rem_added => 'že dodano';
}

// Path: plant_edit
class _Translations$plant_edit$sl extends Translations$plant_edit$en {
	_Translations$plant_edit$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title_edit => 'Uredi rastlino';
	@override String get species => 'Vrsta';
	@override String get alias => 'Osebno ime (neobvezno)';
	@override String get alias_hint => 'npr. »stara jablana ob ograji«';
	@override String get alias_note => 'Vidiš ga samo ti; prikaže se namesto privzetega imena.';
	@override String get location_label => 'Območje';
	@override String get delete => 'Odstrani rastlino iz vrta';
	@override String get delete_note => 'Zgodovina opravil ostane v Dnevniku.';
	@override String get save => 'Shrani';
}

// Path: plant_detail
class _Translations$plant_detail$sl extends Translations$plant_detail$en {
	_Translations$plant_detail$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get not_found => 'Rastlina ni bila najdena.';
	@override String get history_title => 'Zgodovina opravil';
	@override String get history_empty => 'Za to rastlino še ni opravil.';
	@override String get move => 'premakni';
	@override String get assign_area => 'Dodeli območje';
}

// Path: area_pick
class _Translations$area_pick$sl extends Translations$area_pick$en {
	_Translations$area_pick$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String move_title({required Object name}) => 'Premakni „${name}“';
	@override String get choose_title => 'Izberi območje';
	@override String get note => 'Rastlina je lahko v enem območju (ali brez). Zgodovina opravil ostane.';
	@override String get none => 'Brez območja';
	@override String get current => 'trenutno';
	@override String get new_area => 'Novo območje';
	@override String get duplicate => 'Ta rastlina je že v izbranem območju.';
}

// Path: areas
class _Translations$areas$sl extends Translations$areas$en {
	_Translations$areas$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vrt';
	@override String get subtitle => 'rastline in trate';
	@override String get unassigned => 'Brez območja';
	@override String get last_prefix => 'zadnje:';
	@override String get type_lawn => 'Trata';
	@override String get type_hedge => 'Živa meja';
	@override String get type_bed => 'Gredica';
	@override String get type_tree => 'Sadno drevje';
	@override String get type_ornamental => 'Okrasno';
	@override String get type_other => 'Drugo';
	@override String get history_title => 'Zgodovina opravil';
	@override String get history_empty => 'Na tem območju še ni opravil.';
	@override String get plants_section => 'Rastline';
	@override String add_plant_here({required Object area}) => 'Dodaj rastlino v ${area}';
	@override String get delete_reparent_note => 'Rastline iz tega območja se premaknejo v »Brez območja« (ne izbrišejo se).';
	@override String get new_area_inline => 'Novo območje';
	@override String get empty_title => 'Tvoj vrt je še prazen';
	@override String get empty_body => 'Dodaj rastline, ki jih imaš. Območja (grede, trate) so neobvezna.';
	@override String get empty_cta_plant => 'Dodaj rastline';
	@override String get empty_cta_area => 'Dodaj območje';
	@override String get action_edit => 'Uredi';
	@override String get action_delete => 'Izbriši';
	@override String get delete_confirm_title => 'Izbriši območje?';
	@override String get delete_confirm_body => 'Opravila ostanejo, a izgubijo povezavo z območjem.';
	@override String get form_title_new => 'Novo območje';
	@override String get form_title_edit => 'Uredi območje';
	@override String get form_name => 'Ime';
	@override String get form_name_hint => 'npr. Visoka greda 1';
	@override String get form_type => 'Tip';
	@override String get form_save => 'Shrani območje';
	@override String get err_name => 'Vnesi ime območja.';
}

// Path: plants
class _Translations$plants$sl extends Translations$plants$en {
	_Translations$plants$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get picker_title => 'Izberi rastlino';
	@override String get search_hint => 'Išči rastlino…';
	@override String get cat_all => 'Vse';
	@override String get cat_fruit_tree => 'Sadno drevje';
	@override String get cat_berries => 'Jagodičevje';
	@override String get cat_vegetable => 'Zelenjava';
	@override String get cat_herbs => 'Zelišča';
	@override String get cat_ornamental => 'Okrasne';
	@override String get cat_houseplant => 'Sobne';
	@override String get cat_lawn => 'Trata';
	@override String get from_catalog => 'Iz baze';
	@override String get not_found => 'Ne najdeš?';
	@override String custom_add({required Object q}) => '+ Dodaj po meri: »${q}«';
	@override String get custom_private => 'Lasten vnos je zaseben in se ne deli s skupnostjo.';
	@override String get add_title => 'Dodaj rastline';
	@override String get frequent => 'Pogosto';
	@override String get undo => 'Razveljavi';
	@override String get done => 'Končano';
	@override String get add_to_label => 'Kam dodajam';
	@override String get choose_area => 'izberi';
	@override String get field_add => 'Izberi rastlino';
	@override String get field_empty => 'To območje še nima rastlin. Dodaj jo z gumbom spodaj.';
}

// Path: supplies
class _Translations$supplies$sl extends Translations$supplies$en {
	_Translations$supplies$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zaloge';
	@override String get subtitle => 'kaj imam doma';
	@override String get empty => 'Ni zalog. Dodaj jih z +.';
	@override String get low => 'malo';
	@override String qty({required Object q, required Object unit}) => '~${q}${unit}';
	@override String get form_new => 'Novo sredstvo';
	@override String get form_edit => 'Uredi sredstvo';
	@override String get form_name => 'Ime';
	@override String get form_quantity => 'Količina';
	@override String get form_unit => 'Enota';
	@override String get form_threshold => 'Opozori pri (prag)';
	@override String get form_save => 'Shrani';
	@override String get err_name => 'Vnesi ime sredstva.';
	@override String get add_to_task => 'Dodaj sredstvo';
	@override String get pick_new => 'Novo sredstvo';
	@override String get amount => 'Porabljena količina';
	@override String get add_confirm => 'Dodaj';
}

// Path: settings
class _Translations$settings$sl extends Translations$settings$en {
	_Translations$settings$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nastavitve';
	@override String get profile_guest => 'Gost (brez prijave)';
	@override String get sign_in_prompt => 'Prijavi se in shrani podatke v oblak';
	@override String get signed_in => 'Prijavljen — podatki v oblaku';
	@override String get section_location => 'Lokacija';
	@override String get location_placeholder => 'Lokacija za vreme';
	@override String get section_language => 'Jezik';
	@override String get section_notifications => 'Obvestila';
	@override String get notifications_placeholder => 'Obvestila in opomniki';
	@override String get section_garden => 'Vrt';
	@override String get supplies => '📦 Zaloge & sredstva';
	@override String get supplies_sub => 'urea, alge, gnojila, oprema';
	@override String get section_account => 'Račun & podatki';
	@override String get export_data => 'Izvozi podatke (GDPR)';
	@override String get logout => 'Odjava';
	@override String get logout_confirm_title => 'Odjava?';
	@override String get logout_confirm_body => 'Odjavi te in počisti lokalne podatke s te naprave. Sinhronizirani podatki ostanejo v oblaku in se vrnejo ob ponovni prijavi z istim računom.';
	@override String get logout_cancel => 'Prekliči';
	@override String get logout_offline => 'Odjava ni mogoča brez povezave — podatki še niso shranjeni v oblak. Poskusi znova, ko boš povezan.';
	@override String get export_share_text => 'Tendask izvoz podatkov';
	@override String get export_error => 'Izvoz ni uspel. Poskusi znova.';
	@override String get delete_account => 'Izbriši račun in vse podatke';
	@override String get delete_account_confirm_title => 'Izbriši račun?';
	@override String get delete_account_confirm_body => 'Trajno izbriše tvoj račun in vse podatke (opravila, območja, rastline, opombe) — tako v oblaku kot na tej napravi. Tega ni mogoče razveljaviti.';
	@override String get delete_account_confirm => 'Izbriši račun';
	@override String get delete_account_error => 'Izbris ni uspel. Poskusi znova, ko boš povezan.';
	@override String get delete_data => 'Izbriši vse podatke v tej napravi';
	@override String get delete_data_confirm_title => 'Izbriši vse podatke?';
	@override String get delete_data_confirm_body => 'Trajno izbriše vse podatke v tej napravi (opravila, območja, rastline, opombe). Tega ni mogoče razveljaviti.';
	@override String get delete_data_confirm => 'Izbriši';
	@override String get section_about => 'O aplikaciji';
	@override String get privacy_policy => 'Politika zasebnosti';
}

// Path: weather
class _Translations$weather$sl extends Translations$weather$en {
	_Translations$weather$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get cond_clear => 'Jasno';
	@override String get cond_mainly_clear => 'Pretežno jasno';
	@override String get cond_cloudy => 'Oblačno';
	@override String get cond_fog => 'Megla';
	@override String get cond_drizzle => 'Rosenje';
	@override String get cond_rain => 'Dež';
	@override String get cond_snow => 'Sneg';
	@override String get cond_showers => 'Plohe';
	@override String get cond_thunderstorm => 'Nevihta';
	@override String get cond_unknown => '—';
	@override String get band_forecast => 'Napoved';
	@override String get rain_past48h => 'Dež zadnjih 48 h:';
	@override String get detail_waiting => 'Vreme bo zabeleženo, ko označiš opravilo kot opravljeno.';
	@override String get detail_none => 'Vremenski posnetek ni na voljo (zajet brez povezave).';
	@override String get home_unavailable => 'Vreme trenutno ni na voljo.';
	@override String get home_retry => 'Tapni za ponovni poskus';
	@override String get loading => 'Nalagam vreme…';
	@override String updated_at({required Object time}) => 'Osveženo ${time}';
}

/// The flat map containing all translations for locale <sl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsSl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.tagline' => 'Tvoj vrtni dnevnik 🌿',
			'nav.home' => 'Domov',
			'nav.journal' => 'Dnevnik',
			'nav.areas' => 'Vrt',
			'nav.tasks' => 'Opravila',
			'home.greeting' => 'Dober dan 🌿',
			'home.today' => 'Danes',
			'home.recent' => 'Nazadnje',
			'home.no_tasks_today' => 'Danes ni načrtovanih opravil.',
			'home.no_recent' => 'Še ni opravljenih opravil.',
			'home.overdue_banner' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n, one: '1 zamujeno opravilo', two: '${n} zamujeni opravili', few: '${n} zamujena opravila', other: '${n} zamujenih opravil', ), 
			'common.today' => 'Danes',
			'common.yesterday' => 'včeraj',
			'common.load_error' => 'Podatkov ni bilo mogoče naložiti.',
			'swipe.complete' => 'Opravljeno',
			'swipe.postpone' => '+1 dan',
			'swipe.revert' => 'Povrni',
			'swipe.edit' => 'Uredi',
			'swipe.move' => 'Premakni',
			'swipe.delete' => 'Izbriši',
			'notifications.today' => 'Danes',
			'notifications.tomorrow' => 'Jutri',
			'notif_priming.title' => 'Naj te pravočasno opozorim?',
			'notif_priming.why' => 'Da ti opravilo ne uide — opomnik pride takrat, ko si ga nastavil.',
			'notif_priming.benefit_reminders' => 'Opomniki opravil — npr. »1 dan prej ob 18:00«.',
			'notif_priming.benefit_weather' => 'Pametni namig vremena — »jutri suho, primeren čas«. (neobvezno)',
			'notif_priming.benefit_nearby' => 'Namigi okolice — kaj počnejo drugi v tvoji bližini. (V2, neobvezno)',
			'notif_priming.privacy' => 'Vsako vrsto lahko ločeno vklopiš ali izklopiš, nastaviš tihe ure in omejiš pogostost. Brez zasipavanja.',
			'notif_priming.enable' => 'Vklopi obvestila',
			'notif_priming.later' => 'Mogoče kasneje',
			'notif_settings.title' => 'Obvestila',
			'notif_settings.load_error' => 'Nastavitev ni bilo mogoče naložiti.',
			'notif_settings.section_types' => 'Vrste obvestil',
			'notif_settings.type_reminders' => 'Opomniki opravil',
			'notif_settings.type_reminders_sub' => 'lokalno · delujejo brez interneta',
			'notif_settings.type_weather' => 'Pametni namigi (vreme)',
			'notif_settings.type_weather_sub' => 'kmalu · prek strežnika',
			'notif_settings.type_community' => 'Namigi okolice',
			'notif_settings.type_community_sub' => 'kmalu (V2)',
			'notif_settings.section_default_offset' => 'Privzeti zamik opomnika',
			'notif_settings.default_offset_hint' => 'Predizpolni nova opravila; vedno lahko spremeniš.',
			'notif_settings.section_quiet' => 'Da te ne zasipa',
			'notif_settings.quiet_hours' => 'Tihe ure',
			'notif_settings.quiet_hours_sub' => ({required Object range}) => '${range} brez obvestil',
			'notif_settings.frequency_cap' => 'Največ 1 namig na dan',
			'notif_settings.frequency_cap_sub' => 'vreme in okolico združimo v en povzetek',
			'notif_settings.section_more' => 'Več',
			'notif_settings.preview' => 'Predogled obvestil',
			'notif_settings.preview_sub' => 'kako izgledajo na zaklenjenem zaslonu',
			'notif_settings.system_permission' => 'Sistemsko dovoljenje',
			'notif_settings.system_permission_on' => 'naprava: dovoljeno',
			'notif_settings.system_permission_off' => 'točni opomniki niso dovoljeni — tapni za nastavitve',
			'notif_preview.title' => 'Videz obvestil',
			'notif_preview.date' => 'torek, 1. junij',
			'notif_preview.rem_now' => 'zdaj',
			'notif_preview.rem_title' => '⏰ Foliarno škropljenje · 07:00',
			'notif_preview.rem_body' => 'Živa meja + trata · jutro je suho — primeren čas.',
			'notif_preview.rem_tag' => 'opomnik opravila',
			'notif_preview.wx_title' => 'Jutri zjutraj bo suho ☀️',
			'notif_preview.wx_body' => 'Primeren čas za foliarno škropljenje lovorikovcev.',
			'notif_preview.wx_tag' => 'pametni namig · vreme',
			'notif_preview.com_yesterday' => 'včeraj',
			'notif_preview.com_title' => 'Tvoja okolica',
			'notif_preview.com_body' => '68 % vrtnarjev v tvoji okolici je ta teden prvič pognojilo trato.',
			'notif_preview.com_tag' => 'namig okolice · V2',
			'notif_preview.footer' => 'Tap na obvestilo odpre ustrezni zaslon (opravilo · namig · okolica).',
			'onboarding.skip' => 'Preskoči ›',
			'onboarding.next' => 'Naprej',
			'onboarding.start' => 'Začni 🌿',
			'onboarding.soon_badge' => 'kmalu (V2)',
			'onboarding.welcome_title' => 'Dobrodošel v Tendask',
			'onboarding.welcome_body' => 'Tvoj preprost dnevnik za vrt, trato in živo mejo — vsa opravila na enem mestu.',
			'onboarding.log_title' => 'Beleži v sekundi',
			'onboarding.log_body' => 'Pokosil, zalil, pognojil? Zabeleži kaj, kdaj in kje — z nekaj dotiki. Vreme se shrani samodejno.',
			'onboarding.remind_title' => 'Opomniki + vreme',
			'onboarding.remind_body' => 'Načrtuj opravila, prejmi opomnik na telefon in vremenski namig — »jutri zjutraj bo suho, primeren čas za škropljenje«.',
			'onboarding.nearby_title' => 'Tvoja okolica',
			'onboarding.nearby_body' => 'Pozneje poglej, kaj počnejo vrtnarji v podobnem podnebju blizu tebe — anonimno in zasebno.',
			'auth.title' => 'Dobrodošel v Tendask',
			'auth.value_prop' => 'Shrani svoj vrtni dnevnik in ne izgubi zgodovine ob menjavi telefona.',
			'auth.continue_apple' => 'Nadaljuj z Apple',
			'auth.continue_google' => 'Nadaljuj z Google',
			'auth.continue_email' => 'Nadaljuj z e-pošto',
			'auth.guest' => 'Preizkusi brez računa',
			'auth.legal' => 'Z e-pošto pošljemo potrditveno kodo (brez gesla). Nadaljevanje pomeni strinjanje s pogoji in zasebnostjo.',
			'auth.guest_warning' => 'Brez računa se ob odstranitvi aplikacije ali menjavi naprave vsi podatki izgubijo.',
			'auth.google_error' => 'Prijava z Google ni uspela. Poskusi znova.',
			'auth.coming_soon' => 'Na voljo kmalu.',
			'auth.privacy_link' => 'Politika zasebnosti',
			'email_login.title' => 'Prijava z e-pošto',
			'email_login.email_label' => 'E-poštni naslov',
			'email_login.email_hint' => 'ti@primer.si',
			'email_login.send_code' => 'Pošlji kodo',
			'email_login.intro' => 'Poslali ti bomo enkratno kodo — brez gesla.',
			'email_login.code_label' => 'Koda iz e-pošte',
			'email_login.code_hint' => 'Vnesi prejeto kodo',
			'email_login.code_sent' => ({required Object email}) => 'Kodo smo poslali na ${email}. Vpiši jo spodaj.',
			'email_login.verify' => 'Potrdi in se prijavi',
			'email_login.resend' => 'Pošlji novo kodo',
			'email_login.err_email' => 'Vpiši veljaven e-poštni naslov.',
			'email_login.err_code' => 'Vpiši kodo iz e-pošte.',
			'email_login.err_send' => 'Kode ni bilo mogoče poslati. Preveri povezavo in poskusi znova.',
			'email_login.err_verify' => 'Koda ni pravilna ali je potekla. Poskusi znova.',
			'location.title' => 'Kje vrtnariš?',
			'location.why' => 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.',
			'location.use_gps' => 'Uporabi mojo lokacijo',
			'location.or_enter' => 'ali vpiši kraj',
			'location.place_hint' => 'Vas, mesto ali naslov (npr. Šentjur)',
			'location.place_note' => 'Dovolj je vas ali mesto — natančen naslov ni potreben.',
			'location.search' => 'Poišči',
			'location.privacy' => 'Tvojo lokacijo uporabimo le za približno določitev tvoje okolice (širše območje nekaj kilometrov). Natančna lokacija je shranjena le na tvoji napravi — pri nas hranimo samo okvirno okolico in je nikoli ne razkrijemo drugim.',
			'location.kContinue' => 'Nadaljuj',
			'location.set_gps' => 'Lokacija je nastavljena.',
			'location.set_place' => ({required Object name}) => 'Lokacija: ${name}',
			'location.err_denied' => 'Dostop do lokacije je zavrnjen. Vpiši kraj ali omogoči dovoljenje v sistemskih nastavitvah.',
			'location.err_disabled' => 'Lokacijske storitve so izklopljene. Vklopi jih ali vpiši kraj.',
			'location.err_unavailable' => 'Lokacije ni bilo mogoče določiti. Poskusi znova ali vpiši kraj.',
			'location.err_search' => 'Iskanja ni bilo mogoče izvesti. Preveri povezavo in poskusi znova.',
			'location.no_results' => 'Za ta kraj ni zadetkov.',
			'location.screen_title' => 'Lokacija vrta',
			'location.status_set' => 'Lokacija je nastavljena',
			'location.status_unset' => 'Lokacija še ni nastavljena',
			'location.clear' => 'Odstrani lokacijo',
			'location.clear_confirm_title' => 'Odstranim lokacijo?',
			'location.clear_confirm_body' => 'Vreme bo prikazano za privzeto območje, dokler ne nastaviš nove lokacije.',
			'location.clear_confirm_yes' => 'Odstrani',
			'location.clear_confirm_cancel' => 'Prekliči',
			'location.cleared' => 'Lokacija odstranjena',
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
			'journal.month_count' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n, one: '${n} opravilo ta mesec', two: '${n} opravili ta mesec', few: '${n} opravila ta mesec', other: '${n} opravil ta mesec', ), 
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
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n, one: 'zamuja 1 dan', two: 'zamuja ${n} dni', few: 'zamuja ${n} dni', other: 'zamuja ${n} dni', ), 
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
			'subject_picker.choose' => 'Izberi',
			'entry.title_new' => 'Novo opravilo',
			'entry.title_review' => 'Pregled',
			'entry.kContinue' => 'Nadaljuj',
			'entry.skip' => 'Preskoči',
			'entry.save' => 'Shrani opravilo',
			'entry.step' => 'Korak',
			'entry.note_card_title' => 'Le zapis brez opravila?',
			'entry.note_card_action' => 'Opomba ›',
			'entry.repeat_last' => 'Ponovi zadnje',
			'entry.type_title' => 'Katero opravilo?',
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
			'entry.subject_area_note' => 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).',
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
			'entry.rem_custom' => 'Po meri…',
			'entry.rem_unit_min' => 'min',
			'entry.rem_unit_hour' => 'ure',
			'entry.rem_unit_day' => 'dni',
			'entry.rem_custom_label' => 'Koliko prej naj opozorim?',
			'entry.rem_before' => 'prej',
			'entry.rem_at' => ({required Object t}) => 'ob ${t}',
			'entry.rem_choose_time' => 'Ob uri',
			'entry.rem_time_note' => 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).',
			'entry.rem_perm_denied' => 'Obvestila so onemogočena, zato opomnika ni mogoče dodati.',
			'entry.rem_exact_title' => 'Dovoli točne opomnike',
			'entry.rem_exact_body' => 'Za sprožitev ob točnem času Tendask potrebuje dovoljenje »Budilke in opomniki«. Vklopi ga v nastavitvah, nato znova dodaj opomnik.',
			'entry.rem_exact_open' => 'Odpri nastavitve',
			'entry.rem_added' => 'že dodano',
			'plant_edit.title_edit' => 'Uredi rastlino',
			'plant_edit.species' => 'Vrsta',
			'plant_edit.alias' => 'Osebno ime (neobvezno)',
			'plant_edit.alias_hint' => 'npr. »stara jablana ob ograji«',
			'plant_edit.alias_note' => 'Vidiš ga samo ti; prikaže se namesto privzetega imena.',
			'plant_edit.location_label' => 'Območje',
			'plant_edit.delete' => 'Odstrani rastlino iz vrta',
			'plant_edit.delete_note' => 'Zgodovina opravil ostane v Dnevniku.',
			'plant_edit.save' => 'Shrani',
			'plant_detail.not_found' => 'Rastlina ni bila najdena.',
			'plant_detail.history_title' => 'Zgodovina opravil',
			'plant_detail.history_empty' => 'Za to rastlino še ni opravil.',
			'plant_detail.move' => 'premakni',
			'plant_detail.assign_area' => 'Dodeli območje',
			'area_pick.move_title' => ({required Object name}) => 'Premakni „${name}“',
			'area_pick.choose_title' => 'Izberi območje',
			'area_pick.note' => 'Rastlina je lahko v enem območju (ali brez). Zgodovina opravil ostane.',
			'area_pick.none' => 'Brez območja',
			'area_pick.current' => 'trenutno',
			'area_pick.new_area' => 'Novo območje',
			'area_pick.duplicate' => 'Ta rastlina je že v izbranem območju.',
			'areas.title' => 'Vrt',
			'areas.subtitle' => 'rastline in trate',
			'areas.unassigned' => 'Brez območja',
			'areas.last_prefix' => 'zadnje:',
			'areas.type_lawn' => 'Trata',
			'areas.type_hedge' => 'Živa meja',
			'areas.type_bed' => 'Gredica',
			'areas.type_tree' => 'Sadno drevje',
			'areas.type_ornamental' => 'Okrasno',
			'areas.type_other' => 'Drugo',
			'areas.history_title' => 'Zgodovina opravil',
			'areas.history_empty' => 'Na tem območju še ni opravil.',
			'areas.plants_section' => 'Rastline',
			'areas.add_plant_here' => ({required Object area}) => 'Dodaj rastlino v ${area}',
			'areas.delete_reparent_note' => 'Rastline iz tega območja se premaknejo v »Brez območja« (ne izbrišejo se).',
			'areas.new_area_inline' => 'Novo območje',
			'areas.empty_title' => 'Tvoj vrt je še prazen',
			'areas.empty_body' => 'Dodaj rastline, ki jih imaš. Območja (grede, trate) so neobvezna.',
			'areas.empty_cta_plant' => 'Dodaj rastline',
			'areas.empty_cta_area' => 'Dodaj območje',
			'areas.action_edit' => 'Uredi',
			'areas.action_delete' => 'Izbriši',
			'areas.delete_confirm_title' => 'Izbriši območje?',
			'areas.delete_confirm_body' => 'Opravila ostanejo, a izgubijo povezavo z območjem.',
			'areas.form_title_new' => 'Novo območje',
			'areas.form_title_edit' => 'Uredi območje',
			'areas.form_name' => 'Ime',
			'areas.form_name_hint' => 'npr. Visoka greda 1',
			'areas.form_type' => 'Tip',
			'areas.form_save' => 'Shrani območje',
			'areas.err_name' => 'Vnesi ime območja.',
			'plants.picker_title' => 'Izberi rastlino',
			'plants.search_hint' => 'Išči rastlino…',
			'plants.cat_all' => 'Vse',
			'plants.cat_fruit_tree' => 'Sadno drevje',
			'plants.cat_berries' => 'Jagodičevje',
			'plants.cat_vegetable' => 'Zelenjava',
			'plants.cat_herbs' => 'Zelišča',
			'plants.cat_ornamental' => 'Okrasne',
			'plants.cat_houseplant' => 'Sobne',
			'plants.cat_lawn' => 'Trata',
			'plants.from_catalog' => 'Iz baze',
			'plants.not_found' => 'Ne najdeš?',
			'plants.custom_add' => ({required Object q}) => '+ Dodaj po meri: »${q}«',
			'plants.custom_private' => 'Lasten vnos je zaseben in se ne deli s skupnostjo.',
			'plants.add_title' => 'Dodaj rastline',
			'plants.frequent' => 'Pogosto',
			'plants.undo' => 'Razveljavi',
			'plants.done' => 'Končano',
			'plants.add_to_label' => 'Kam dodajam',
			'plants.choose_area' => 'izberi',
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
			'settings.sign_in_prompt' => 'Prijavi se in shrani podatke v oblak',
			'settings.signed_in' => 'Prijavljen — podatki v oblaku',
			'settings.section_location' => 'Lokacija',
			'settings.location_placeholder' => 'Lokacija za vreme',
			'settings.section_language' => 'Jezik',
			'settings.section_notifications' => 'Obvestila',
			'settings.notifications_placeholder' => 'Obvestila in opomniki',
			'settings.section_garden' => 'Vrt',
			'settings.supplies' => '📦 Zaloge & sredstva',
			'settings.supplies_sub' => 'urea, alge, gnojila, oprema',
			'settings.section_account' => 'Račun & podatki',
			'settings.export_data' => 'Izvozi podatke (GDPR)',
			'settings.logout' => 'Odjava',
			'settings.logout_confirm_title' => 'Odjava?',
			'settings.logout_confirm_body' => 'Odjavi te in počisti lokalne podatke s te naprave. Sinhronizirani podatki ostanejo v oblaku in se vrnejo ob ponovni prijavi z istim računom.',
			'settings.logout_cancel' => 'Prekliči',
			'settings.logout_offline' => 'Odjava ni mogoča brez povezave — podatki še niso shranjeni v oblak. Poskusi znova, ko boš povezan.',
			'settings.export_share_text' => 'Tendask izvoz podatkov',
			'settings.export_error' => 'Izvoz ni uspel. Poskusi znova.',
			'settings.delete_account' => 'Izbriši račun in vse podatke',
			'settings.delete_account_confirm_title' => 'Izbriši račun?',
			'settings.delete_account_confirm_body' => 'Trajno izbriše tvoj račun in vse podatke (opravila, območja, rastline, opombe) — tako v oblaku kot na tej napravi. Tega ni mogoče razveljaviti.',
			'settings.delete_account_confirm' => 'Izbriši račun',
			'settings.delete_account_error' => 'Izbris ni uspel. Poskusi znova, ko boš povezan.',
			'settings.delete_data' => 'Izbriši vse podatke v tej napravi',
			'settings.delete_data_confirm_title' => 'Izbriši vse podatke?',
			'settings.delete_data_confirm_body' => 'Trajno izbriše vse podatke v tej napravi (opravila, območja, rastline, opombe). Tega ni mogoče razveljaviti.',
			'settings.delete_data_confirm' => 'Izbriši',
			'settings.section_about' => 'O aplikaciji',
			'settings.privacy_policy' => 'Politika zasebnosti',
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
			'weather.home_retry' => 'Tapni za ponovni poskus',
			'weather.loading' => 'Nalagam vreme…',
			'weather.updated_at' => ({required Object time}) => 'Osveženo ${time}',
			_ => null,
		};
	}
}

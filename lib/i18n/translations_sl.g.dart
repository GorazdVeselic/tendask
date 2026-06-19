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
	@override late final _Translations$suggestions$sl suggestions = _Translations$suggestions$sl._(_root);
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
	@override String get type_weather_sub => '»jutri suho — primeren čas«';
	@override String get type_community => 'Namigi okolice';
	@override String get type_community_sub => 'kaj počnejo drugi v bližini';
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
	@override String get hints_perm_denied => 'Obvestila so onemogočena, zato namigov ni mogoče vklopiti.';
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
	@override String get err_email_domain => 'Domene tega e-naslova ne najdemo. Preveri naslov.';
	@override String did_you_mean({required Object suggestion}) => 'Ste mislili ${suggestion}?';
	@override String resend_in({required Object seconds}) => 'Pošlji novo kodo (${seconds} s)';
}

// Path: location
class _Translations$location$sl extends Translations$location$en {
	_Translations$location$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kje vrtnariš?';
	@override String get why => 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.';
	@override String get use_gps => 'Uporabi mojo lokacijo';
	@override String get enter_place => 'Vpiši kraj';
	@override String get or => 'ali';
	@override String get gps_sub => 'Samodejno z GPS naprave';
	@override String get place_hint => 'Vas, mesto ali naslov (npr. Šentjur)';
	@override String get place_note => 'Dovolj je vas ali mesto — natančen naslov ni potreben.';
	@override String get search => 'Poišči';
	@override String get privacy => 'Natančne lokacije nikoli ne shranjujemo. Shranimo samo približno okolico (širše območje nekaj km), ki je nikoli ne razkrijemo drugim.';
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
	@override String status_set_at({required Object name}) => 'Lokacija je nastavljena · ${name}';
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
	@override String get type_garden => 'Vrt';
	@override String get type_lawn => 'Trata';
	@override String get type_hedge => 'Živa meja';
	@override String get type_bed => 'Gredica';
	@override String get type_tree => 'Sadno drevje';
	@override String get type_ornamental => 'Okrasno';
	@override String get type_other => 'Drugo';
	@override String get default_garden_name => 'Vrt';
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
	@override String get section_suggestions => 'Predlogi';
	@override String get suggestions_history_sub => 'Kaj je bilo predlagano in kako si se odzval';
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
	@override String get m_humidity => 'Vlažnost';
	@override String get m_wind => 'Veter';
	@override String get m_precipitation => 'Padavine';
	@override String get m_soil_temp => 'Temp. tal';
	@override String get m_et0 => 'ET₀';
	@override String get m_rain48h => 'Dež 48 h';
	@override String get m_no_rain => 'brez dežja';
}

// Path: suggestions
class _Translations$suggestions$sl extends Translations$suggestions$en {
	_Translations$suggestions$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$actions$sl actions = _Translations$suggestions$actions$sl._(_root);
	@override late final _Translations$suggestions$toast$sl toast = _Translations$suggestions$toast$sl._(_root);
	@override String get disclaimer => 'Predlogi so splošna usmeritev — tvoj vrt najbolje poznaš ti.';
	@override late final _Translations$suggestions$done_sheet$sl done_sheet = _Translations$suggestions$done_sheet$sl._(_root);
	@override late final _Translations$suggestions$remove$sl remove = _Translations$suggestions$remove$sl._(_root);
	@override late final _Translations$suggestions$history_status$sl history_status = _Translations$suggestions$history_status$sl._(_root);
	@override String get band_title => 'Predlogi zate';
	@override String get past_link => 'Zgodovina';
	@override String get past_title => 'Pretekli predlogi';
	@override String get past_intro => 'Kaj ti je Tendask predlagal in kako si se odzval.';
	@override String get past_empty => 'Še ni zgodovine. Ko se odzoveš na predlog — ga načrtuješ, opustiš ali zabeležiš kot opravljeno — se zapis pojavi tukaj.';
	@override String get past_retention => 'Predloge starejše od enega leta samodejno počistimo.';
	@override late final _Translations$suggestions$cadence$sl cadence = _Translations$suggestions$cadence$sl._(_root);
	@override late final _Translations$suggestions$history$sl history = _Translations$suggestions$history$sl._(_root);
	@override late final _Translations$suggestions$weather$sl weather = _Translations$suggestions$weather$sl._(_root);
	@override late final _Translations$suggestions$community$sl community = _Translations$suggestions$community$sl._(_root);
	@override late final _Translations$suggestions$lawn$sl lawn = _Translations$suggestions$lawn$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$sl fruit_tree = _Translations$suggestions$fruit_tree$sl._(_root);
	@override late final _Translations$suggestions$berries$sl berries = _Translations$suggestions$berries$sl._(_root);
	@override late final _Translations$suggestions$vegetable$sl vegetable = _Translations$suggestions$vegetable$sl._(_root);
	@override late final _Translations$suggestions$herbs$sl herbs = _Translations$suggestions$herbs$sl._(_root);
	@override late final _Translations$suggestions$tomato$sl tomato = _Translations$suggestions$tomato$sl._(_root);
	@override late final _Translations$suggestions$shrub$sl shrub = _Translations$suggestions$shrub$sl._(_root);
	@override late final _Translations$suggestions$hedge$sl hedge = _Translations$suggestions$hedge$sl._(_root);
	@override late final _Translations$suggestions$conifer$sl conifer = _Translations$suggestions$conifer$sl._(_root);
	@override late final _Translations$suggestions$houseplant$sl houseplant = _Translations$suggestions$houseplant$sl._(_root);
	@override late final _Translations$suggestions$blueberry$sl blueberry = _Translations$suggestions$blueberry$sl._(_root);
	@override late final _Translations$suggestions$cherry_laurel$sl cherry_laurel = _Translations$suggestions$cherry_laurel$sl._(_root);
	@override late final _Translations$suggestions$hydrangea$sl hydrangea = _Translations$suggestions$hydrangea$sl._(_root);
	@override late final _Translations$suggestions$peach$sl peach = _Translations$suggestions$peach$sl._(_root);
	@override late final _Translations$suggestions$raspberry$sl raspberry = _Translations$suggestions$raspberry$sl._(_root);
	@override late final _Translations$suggestions$rose$sl rose = _Translations$suggestions$rose$sl._(_root);
	@override late final _Translations$suggestions$cucumber$sl cucumber = _Translations$suggestions$cucumber$sl._(_root);
	@override late final _Translations$suggestions$zucchini$sl zucchini = _Translations$suggestions$zucchini$sl._(_root);
}

// Path: suggestions.actions
class _Translations$suggestions$actions$sl extends Translations$suggestions$actions$en {
	_Translations$suggestions$actions$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get plan => 'Načrtuj';
	@override String get dismiss => 'Preskoči';
	@override String get already_done => 'Že opravljeno';
	@override String get never => 'Ne predlagaj več';
	@override String get remove_subject => 'Tega nimam več';
}

// Path: suggestions.toast
class _Translations$suggestions$toast$sl extends Translations$suggestions$toast$en {
	_Translations$suggestions$toast$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get planned => 'Dodano med opravila';
	@override String get logged => 'Zabeleženo kot opravljeno';
}

// Path: suggestions.done_sheet
class _Translations$suggestions$done_sheet$sl extends Translations$suggestions$done_sheet$en {
	_Translations$suggestions$done_sheet$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kdaj je bilo opravljeno?';
	@override String get today => 'Danes';
	@override String get yesterday => 'Včeraj';
	@override String get pick => 'Izberi datum…';
}

// Path: suggestions.remove
class _Translations$suggestions$remove$sl extends Translations$suggestions$remove$en {
	_Translations$suggestions$remove$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Odstranim?';
	@override String get body => '{subject} odstrani iz vrta in ustavi njegove predloge. Pretekli zapisi ostanejo.';
	@override String get confirm => 'Odstrani';
}

// Path: suggestions.history_status
class _Translations$suggestions$history_status$sl extends Translations$suggestions$history_status$en {
	_Translations$suggestions$history_status$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get planned => 'Načrtovano';
	@override String get logged => 'Zabeleženo';
	@override String get dismissed => 'Opuščeno';
	@override String get muted => 'Utišano';
	@override String get missed => 'Zamujeno';
}

// Path: suggestions.cadence
class _Translations$suggestions$cadence$sl extends Translations$suggestions$cadence$en {
	_Translations$suggestions$cadence$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cadence$overdue$sl overdue = _Translations$suggestions$cadence$overdue$sl._(_root);
}

// Path: suggestions.history
class _Translations$suggestions$history$sl extends Translations$suggestions$history$en {
	_Translations$suggestions$history$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$history$anniversary$sl anniversary = _Translations$suggestions$history$anniversary$sl._(_root);
}

// Path: suggestions.weather
class _Translations$suggestions$weather$sl extends Translations$suggestions$weather$en {
	_Translations$suggestions$weather$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$weather$window_open$sl window_open = _Translations$suggestions$weather$window_open$sl._(_root);
}

// Path: suggestions.community
class _Translations$suggestions$community$sl extends Translations$suggestions$community$en {
	_Translations$suggestions$community$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$community$most_started$sl most_started = _Translations$suggestions$community$most_started$sl._(_root);
}

// Path: suggestions.lawn
class _Translations$suggestions$lawn$sl extends Translations$suggestions$lawn$en {
	_Translations$suggestions$lawn$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$lawn$mow_due$sl mow_due = _Translations$suggestions$lawn$mow_due$sl._(_root);
	@override late final _Translations$suggestions$lawn$water_drought$sl water_drought = _Translations$suggestions$lawn$water_drought$sl._(_root);
	@override late final _Translations$suggestions$lawn$fertilize_spring$sl fertilize_spring = _Translations$suggestions$lawn$fertilize_spring$sl._(_root);
	@override late final _Translations$suggestions$lawn$fertilize_autumn$sl fertilize_autumn = _Translations$suggestions$lawn$fertilize_autumn$sl._(_root);
	@override late final _Translations$suggestions$lawn$lime$sl lime = _Translations$suggestions$lawn$lime$sl._(_root);
	@override late final _Translations$suggestions$lawn$moss_control$sl moss_control = _Translations$suggestions$lawn$moss_control$sl._(_root);
	@override late final _Translations$suggestions$lawn$weed_control$sl weed_control = _Translations$suggestions$lawn$weed_control$sl._(_root);
	@override late final _Translations$suggestions$lawn$overseed_spring$sl overseed_spring = _Translations$suggestions$lawn$overseed_spring$sl._(_root);
	@override late final _Translations$suggestions$lawn$overseed_autumn$sl overseed_autumn = _Translations$suggestions$lawn$overseed_autumn$sl._(_root);
	@override late final _Translations$suggestions$lawn$scarify_spring$sl scarify_spring = _Translations$suggestions$lawn$scarify_spring$sl._(_root);
	@override late final _Translations$suggestions$lawn$scarify_autumn$sl scarify_autumn = _Translations$suggestions$lawn$scarify_autumn$sl._(_root);
	@override late final _Translations$suggestions$lawn$aerate$sl aerate = _Translations$suggestions$lawn$aerate$sl._(_root);
	@override late final _Translations$suggestions$lawn$roll$sl roll = _Translations$suggestions$lawn$roll$sl._(_root);
	@override late final _Translations$suggestions$lawn$topdress$sl topdress = _Translations$suggestions$lawn$topdress$sl._(_root);
}

// Path: suggestions.fruit_tree
class _Translations$suggestions$fruit_tree$sl extends Translations$suggestions$fruit_tree$en {
	_Translations$suggestions$fruit_tree$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$fruit_tree$fertilize_spring$sl fertilize_spring = _Translations$suggestions$fruit_tree$fertilize_spring$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$prune_winter$sl prune_winter = _Translations$suggestions$fruit_tree$prune_winter$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$treat_dormant$sl treat_dormant = _Translations$suggestions$fruit_tree$treat_dormant$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$mulch$sl mulch = _Translations$suggestions$fruit_tree$mulch$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$thin_fruit$sl thin_fruit = _Translations$suggestions$fruit_tree$thin_fruit$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$graft_spring$sl graft_spring = _Translations$suggestions$fruit_tree$graft_spring$sl._(_root);
	@override late final _Translations$suggestions$fruit_tree$graft_budding$sl graft_budding = _Translations$suggestions$fruit_tree$graft_budding$sl._(_root);
}

// Path: suggestions.berries
class _Translations$suggestions$berries$sl extends Translations$suggestions$berries$en {
	_Translations$suggestions$berries$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$berries$prune_winter$sl prune_winter = _Translations$suggestions$berries$prune_winter$sl._(_root);
	@override late final _Translations$suggestions$berries$fertilize_spring$sl fertilize_spring = _Translations$suggestions$berries$fertilize_spring$sl._(_root);
	@override late final _Translations$suggestions$berries$mulch$sl mulch = _Translations$suggestions$berries$mulch$sl._(_root);
	@override late final _Translations$suggestions$berries$treat_dormant$sl treat_dormant = _Translations$suggestions$berries$treat_dormant$sl._(_root);
}

// Path: suggestions.vegetable
class _Translations$suggestions$vegetable$sl extends Translations$suggestions$vegetable$en {
	_Translations$suggestions$vegetable$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$vegetable$start_seedlings$sl start_seedlings = _Translations$suggestions$vegetable$start_seedlings$sl._(_root);
	@override late final _Translations$suggestions$vegetable$prick_out$sl prick_out = _Translations$suggestions$vegetable$prick_out$sl._(_root);
	@override late final _Translations$suggestions$vegetable$harden_off$sl harden_off = _Translations$suggestions$vegetable$harden_off$sl._(_root);
	@override late final _Translations$suggestions$vegetable$plant_out$sl plant_out = _Translations$suggestions$vegetable$plant_out$sl._(_root);
	@override late final _Translations$suggestions$vegetable$transplant$sl transplant = _Translations$suggestions$vegetable$transplant$sl._(_root);
	@override late final _Translations$suggestions$vegetable$sow_direct$sl sow_direct = _Translations$suggestions$vegetable$sow_direct$sl._(_root);
	@override late final _Translations$suggestions$vegetable$fertilize_season$sl fertilize_season = _Translations$suggestions$vegetable$fertilize_season$sl._(_root);
	@override late final _Translations$suggestions$vegetable$treat_window$sl treat_window = _Translations$suggestions$vegetable$treat_window$sl._(_root);
}

// Path: suggestions.herbs
class _Translations$suggestions$herbs$sl extends Translations$suggestions$herbs$en {
	_Translations$suggestions$herbs$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$herbs$start_seedlings$sl start_seedlings = _Translations$suggestions$herbs$start_seedlings$sl._(_root);
	@override late final _Translations$suggestions$herbs$sow_direct$sl sow_direct = _Translations$suggestions$herbs$sow_direct$sl._(_root);
	@override late final _Translations$suggestions$herbs$plant_out$sl plant_out = _Translations$suggestions$herbs$plant_out$sl._(_root);
}

// Path: suggestions.tomato
class _Translations$suggestions$tomato$sl extends Translations$suggestions$tomato$en {
	_Translations$suggestions$tomato$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$tomato$start_seedlings$sl start_seedlings = _Translations$suggestions$tomato$start_seedlings$sl._(_root);
	@override late final _Translations$suggestions$tomato$prick_out$sl prick_out = _Translations$suggestions$tomato$prick_out$sl._(_root);
	@override late final _Translations$suggestions$tomato$harden_off$sl harden_off = _Translations$suggestions$tomato$harden_off$sl._(_root);
	@override late final _Translations$suggestions$tomato$transplant$sl transplant = _Translations$suggestions$tomato$transplant$sl._(_root);
	@override late final _Translations$suggestions$tomato$stake$sl stake = _Translations$suggestions$tomato$stake$sl._(_root);
}

// Path: suggestions.shrub
class _Translations$suggestions$shrub$sl extends Translations$suggestions$shrub$en {
	_Translations$suggestions$shrub$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$shrub$prune_spring$sl prune_spring = _Translations$suggestions$shrub$prune_spring$sl._(_root);
	@override late final _Translations$suggestions$shrub$overwinter$sl overwinter = _Translations$suggestions$shrub$overwinter$sl._(_root);
}

// Path: suggestions.hedge
class _Translations$suggestions$hedge$sl extends Translations$suggestions$hedge$en {
	_Translations$suggestions$hedge$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$hedge$prune_early_summer$sl prune_early_summer = _Translations$suggestions$hedge$prune_early_summer$sl._(_root);
	@override late final _Translations$suggestions$hedge$prune_late_summer$sl prune_late_summer = _Translations$suggestions$hedge$prune_late_summer$sl._(_root);
}

// Path: suggestions.conifer
class _Translations$suggestions$conifer$sl extends Translations$suggestions$conifer$en {
	_Translations$suggestions$conifer$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$conifer$prune$sl prune = _Translations$suggestions$conifer$prune$sl._(_root);
}

// Path: suggestions.houseplant
class _Translations$suggestions$houseplant$sl extends Translations$suggestions$houseplant$en {
	_Translations$suggestions$houseplant$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$houseplant$repot$sl repot = _Translations$suggestions$houseplant$repot$sl._(_root);
	@override late final _Translations$suggestions$houseplant$fertilize_season$sl fertilize_season = _Translations$suggestions$houseplant$fertilize_season$sl._(_root);
	@override late final _Translations$suggestions$houseplant$overwinter$sl overwinter = _Translations$suggestions$houseplant$overwinter$sl._(_root);
}

// Path: suggestions.blueberry
class _Translations$suggestions$blueberry$sl extends Translations$suggestions$blueberry$en {
	_Translations$suggestions$blueberry$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$blueberry$prune$sl prune = _Translations$suggestions$blueberry$prune$sl._(_root);
}

// Path: suggestions.cherry_laurel
class _Translations$suggestions$cherry_laurel$sl extends Translations$suggestions$cherry_laurel$en {
	_Translations$suggestions$cherry_laurel$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cherry_laurel$prune_late_spring$sl prune_late_spring = _Translations$suggestions$cherry_laurel$prune_late_spring$sl._(_root);
	@override late final _Translations$suggestions$cherry_laurel$prune_late_summer$sl prune_late_summer = _Translations$suggestions$cherry_laurel$prune_late_summer$sl._(_root);
}

// Path: suggestions.hydrangea
class _Translations$suggestions$hydrangea$sl extends Translations$suggestions$hydrangea$en {
	_Translations$suggestions$hydrangea$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$hydrangea$prune_old_wood$sl prune_old_wood = _Translations$suggestions$hydrangea$prune_old_wood$sl._(_root);
	@override late final _Translations$suggestions$hydrangea$prune_new_wood$sl prune_new_wood = _Translations$suggestions$hydrangea$prune_new_wood$sl._(_root);
}

// Path: suggestions.peach
class _Translations$suggestions$peach$sl extends Translations$suggestions$peach$en {
	_Translations$suggestions$peach$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$peach$prune_spring$sl prune_spring = _Translations$suggestions$peach$prune_spring$sl._(_root);
}

// Path: suggestions.raspberry
class _Translations$suggestions$raspberry$sl extends Translations$suggestions$raspberry$en {
	_Translations$suggestions$raspberry$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$raspberry$prune_late_winter$sl prune_late_winter = _Translations$suggestions$raspberry$prune_late_winter$sl._(_root);
	@override late final _Translations$suggestions$raspberry$prune_after_harvest$sl prune_after_harvest = _Translations$suggestions$raspberry$prune_after_harvest$sl._(_root);
}

// Path: suggestions.rose
class _Translations$suggestions$rose$sl extends Translations$suggestions$rose$en {
	_Translations$suggestions$rose$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$rose$prune_spring$sl prune_spring = _Translations$suggestions$rose$prune_spring$sl._(_root);
	@override late final _Translations$suggestions$rose$overwinter$sl overwinter = _Translations$suggestions$rose$overwinter$sl._(_root);
}

// Path: suggestions.cucumber
class _Translations$suggestions$cucumber$sl extends Translations$suggestions$cucumber$en {
	_Translations$suggestions$cucumber$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cucumber$sow_direct$sl sow_direct = _Translations$suggestions$cucumber$sow_direct$sl._(_root);
}

// Path: suggestions.zucchini
class _Translations$suggestions$zucchini$sl extends Translations$suggestions$zucchini$en {
	_Translations$suggestions$zucchini$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$zucchini$sow_direct$sl sow_direct = _Translations$suggestions$zucchini$sow_direct$sl._(_root);
}

// Path: suggestions.cadence.overdue
class _Translations$suggestions$cadence$overdue$sl extends Translations$suggestions$cadence$overdue$en {
	_Translations$suggestions$cadence$overdue$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} je na vrsti';
	@override String get body => '{subject}: zamuda približno {days_overdue} dni (običajni ritem ~{cadence_days} dni).';
}

// Path: suggestions.history.anniversary
class _Translations$suggestions$history$anniversary$sl extends Translations$suggestions$history$anniversary$en {
	_Translations$suggestions$history$anniversary$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} — pred letom dni';
	@override String get body => 'Lani okoli {last_year_date} — {task} pri {subject}. Morda spet?';
}

// Path: suggestions.weather.window_open
class _Translations$suggestions$weather$window_open$sl extends Translations$suggestions$weather$window_open$en {
	_Translations$suggestions$weather$window_open$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => '{task}: ugodno okno';
	@override String get body => 'Za {subject} prihaja suho obdobje — primeren čas.';
}

// Path: suggestions.community.most_started
class _Translations$suggestions$community$most_started$sl extends Translations$suggestions$community$most_started$en {
	_Translations$suggestions$community$most_started$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} v okolici';
	@override String get body => 'Približno {percent} % vrtnarjev v tvoji okolici je to letos že začelo.';
}

// Path: suggestions.lawn.mow_due
class _Translations$suggestions$lawn$mow_due$sl extends Translations$suggestions$lawn$mow_due$en {
	_Translations$suggestions$lawn$mow_due$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Čas za košnjo';
	@override String get body => '{subject}: čas za košnjo.';
}

// Path: suggestions.lawn.water_drought
class _Translations$suggestions$lawn$water_drought$sl extends Translations$suggestions$lawn$water_drought$en {
	_Translations$suggestions$lawn$water_drought$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zalivanje v suši';
	@override String get body => '{subject} ob suši morda potrebuje zalivanje.';
}

// Path: suggestions.lawn.fertilize_spring
class _Translations$suggestions$lawn$fertilize_spring$sl extends Translations$suggestions$lawn$fertilize_spring$en {
	_Translations$suggestions$lawn$fertilize_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladansko gnojenje';
	@override String get body => 'Pognoji {subject} za sezono — najbolje do približno {window_end_date}.';
}

// Path: suggestions.lawn.fertilize_autumn
class _Translations$suggestions$lawn$fertilize_autumn$sl extends Translations$suggestions$lawn$fertilize_autumn$en {
	_Translations$suggestions$lawn$fertilize_autumn$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jesensko gnojenje';
	@override String get body => 'Jesensko pognoji {subject} pred zimo — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.lawn.lime
class _Translations$suggestions$lawn$lime$sl extends Translations$suggestions$lawn$lime$en {
	_Translations$suggestions$lawn$lime$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Apnenje trate';
	@override String get body => 'Če so tla kisla, apni {subject} — do približno {window_end_date}.';
}

// Path: suggestions.lawn.moss_control
class _Translations$suggestions$lawn$moss_control$sl extends Translations$suggestions$lawn$moss_control$en {
	_Translations$suggestions$lawn$moss_control$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zatiranje mahu';
	@override String get body => 'Zatri mah pri {subject} — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.lawn.weed_control
class _Translations$suggestions$lawn$weed_control$sl extends Translations$suggestions$lawn$weed_control$en {
	_Translations$suggestions$lawn$weed_control$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zatiranje plevela';
	@override String get body => 'Loti se plevela pri {subject} — najbolje do približno {window_end_date}.';
}

// Path: suggestions.lawn.overseed_spring
class _Translations$suggestions$lawn$overseed_spring$sl extends Translations$suggestions$lawn$overseed_spring$en {
	_Translations$suggestions$lawn$overseed_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dosejavanje (pomlad)';
	@override String get body => 'Dosej redke dele pri {subject} — do približno {window_end_date}.';
}

// Path: suggestions.lawn.overseed_autumn
class _Translations$suggestions$lawn$overseed_autumn$sl extends Translations$suggestions$lawn$overseed_autumn$en {
	_Translations$suggestions$lawn$overseed_autumn$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dosejavanje (jesen)';
	@override String get body => 'Jeseni dosej {subject} — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.lawn.scarify_spring
class _Translations$suggestions$lawn$scarify_spring$sl extends Translations$suggestions$lawn$scarify_spring$en {
	_Translations$suggestions$lawn$scarify_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vertikutiranje (pomlad)';
	@override String get body => 'Odstrani travni filc pri {subject} — do približno {window_end_date}.';
}

// Path: suggestions.lawn.scarify_autumn
class _Translations$suggestions$lawn$scarify_autumn$sl extends Translations$suggestions$lawn$scarify_autumn$en {
	_Translations$suggestions$lawn$scarify_autumn$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vertikutiranje (jesen)';
	@override String get body => 'Jeseni vertikutiraj {subject} — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.lawn.aerate
class _Translations$suggestions$lawn$aerate$sl extends Translations$suggestions$lawn$aerate$en {
	_Translations$suggestions$lawn$aerate$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prezračevanje';
	@override String get body => 'Prezrači {subject} za manjšo zbitost — do približno {window_end_date}.';
}

// Path: suggestions.lawn.roll
class _Translations$suggestions$lawn$roll$sl extends Translations$suggestions$lawn$roll$en {
	_Translations$suggestions$lawn$roll$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Valjanje trate';
	@override String get body => 'Po zimi povaljaj {subject} — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.lawn.topdress
class _Translations$suggestions$lawn$topdress$sl extends Translations$suggestions$lawn$topdress$en {
	_Translations$suggestions$lawn$topdress$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nasipavanje';
	@override String get body => 'Nasuj in poravnaj {subject} — do približno {window_end_date}.';
}

// Path: suggestions.fruit_tree.fertilize_spring
class _Translations$suggestions$fruit_tree$fertilize_spring$sl extends Translations$suggestions$fruit_tree$fertilize_spring$en {
	_Translations$suggestions$fruit_tree$fertilize_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladansko gnojenje';
	@override String get body => 'Pognoji {subject} ob začetku rasti — do približno {window_end_date}.';
}

// Path: suggestions.fruit_tree.prune_winter
class _Translations$suggestions$fruit_tree$prune_winter$sl extends Translations$suggestions$fruit_tree$prune_winter$en {
	_Translations$suggestions$fruit_tree$prune_winter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimska rez';
	@override String get body => 'Obreži {subject} v mirovanju — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.treat_dormant
class _Translations$suggestions$fruit_tree$treat_dormant$sl extends Translations$suggestions$fruit_tree$treat_dormant$en {
	_Translations$suggestions$fruit_tree$treat_dormant$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimsko škropljenje';
	@override String get body => 'Opravi zimsko škropljenje pri {subject} — do približno {window_end_date}.';
}

// Path: suggestions.fruit_tree.mulch
class _Translations$suggestions$fruit_tree$mulch$sl extends Translations$suggestions$fruit_tree$mulch$en {
	_Translations$suggestions$fruit_tree$mulch$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zastiranje';
	@override String get body => 'Zastri okolico {subject} za ohranjanje vlage — do približno {window_end_date}.';
}

// Path: suggestions.fruit_tree.thin_fruit
class _Translations$suggestions$fruit_tree$thin_fruit$sl extends Translations$suggestions$fruit_tree$thin_fruit$en {
	_Translations$suggestions$fruit_tree$thin_fruit$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Redčenje plodov';
	@override String get body => 'Razredči plodiče pri {subject} za boljšo velikost — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_spring
class _Translations$suggestions$fruit_tree$graft_spring$sl extends Translations$suggestions$fruit_tree$graft_spring$en {
	_Translations$suggestions$fruit_tree$graft_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladansko cepljenje';
	@override String get body => 'Cepi {subject} ob dvigu soka — do približno {window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_budding
class _Translations$suggestions$fruit_tree$graft_budding$sl extends Translations$suggestions$fruit_tree$graft_budding$en {
	_Translations$suggestions$fruit_tree$graft_budding$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Poletno okuliranje';
	@override String get body => 'Okuliraj {subject} v poznem poletju — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.berries.prune_winter
class _Translations$suggestions$berries$prune_winter$sl extends Translations$suggestions$berries$prune_winter$en {
	_Translations$suggestions$berries$prune_winter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimska rez';
	@override String get body => 'Obreži {subject} v mirovanju — do približno {window_end_date}.';
}

// Path: suggestions.berries.fertilize_spring
class _Translations$suggestions$berries$fertilize_spring$sl extends Translations$suggestions$berries$fertilize_spring$en {
	_Translations$suggestions$berries$fertilize_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladansko gnojenje';
	@override String get body => 'Pognoji {subject} ob začetku rasti — do približno {window_end_date}.';
}

// Path: suggestions.berries.mulch
class _Translations$suggestions$berries$mulch$sl extends Translations$suggestions$berries$mulch$en {
	_Translations$suggestions$berries$mulch$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zastiranje';
	@override String get body => 'Zastri {subject} za hladne in vlažne korenine — do približno {window_end_date}.';
}

// Path: suggestions.berries.treat_dormant
class _Translations$suggestions$berries$treat_dormant$sl extends Translations$suggestions$berries$treat_dormant$en {
	_Translations$suggestions$berries$treat_dormant$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimsko škropljenje';
	@override String get body => 'Opravi zimsko škropljenje pri {subject} — do približno {window_end_date}.';
}

// Path: suggestions.vegetable.start_seedlings
class _Translations$suggestions$vegetable$start_seedlings$sl extends Translations$suggestions$vegetable$start_seedlings$en {
	_Translations$suggestions$vegetable$start_seedlings$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Setev za sadike';
	@override String get body => 'Posej {subject} v zavetju za prednost pred saditvijo — do približno {window_end_date}.';
}

// Path: suggestions.vegetable.prick_out
class _Translations$suggestions$vegetable$prick_out$sl extends Translations$suggestions$vegetable$prick_out$en {
	_Translations$suggestions$vegetable$prick_out$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pikiranje';
	@override String get body => 'Od setve {subject} je {days_since} dni — pikiraj sadike v lončke.';
}

// Path: suggestions.vegetable.harden_off
class _Translations$suggestions$vegetable$harden_off$sl extends Translations$suggestions$vegetable$harden_off$en {
	_Translations$suggestions$vegetable$harden_off$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Utrjevanje sadik';
	@override String get body => 'Utrdi {subject} na prostem pred saditvijo — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.vegetable.plant_out
class _Translations$suggestions$vegetable$plant_out$sl extends Translations$suggestions$vegetable$plant_out$en {
	_Translations$suggestions$vegetable$plant_out$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Saditev na prosto';
	@override String get body => 'Posadi {subject} na prosto, ko mine pozeba — okoli {frost_date}.';
}

// Path: suggestions.vegetable.transplant
class _Translations$suggestions$vegetable$transplant$sl extends Translations$suggestions$vegetable$transplant$en {
	_Translations$suggestions$vegetable$transplant$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Presaditev';
	@override String get body => 'Presadi {subject} na končno mesto po pozebi — okoli {frost_date}.';
}

// Path: suggestions.vegetable.sow_direct
class _Translations$suggestions$vegetable$sow_direct$sl extends Translations$suggestions$vegetable$sow_direct$en {
	_Translations$suggestions$vegetable$sow_direct$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Neposredna setev';
	@override String get body => 'Posej {subject} naravnost na prosto, ko se otopli — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.vegetable.fertilize_season
class _Translations$suggestions$vegetable$fertilize_season$sl extends Translations$suggestions$vegetable$fertilize_season$en {
	_Translations$suggestions$vegetable$fertilize_season$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dognojevanje';
	@override String get body => 'Med rastno dobo pognoji {subject}.';
}

// Path: suggestions.vegetable.treat_window
class _Translations$suggestions$vegetable$treat_window$sl extends Translations$suggestions$vegetable$treat_window$en {
	_Translations$suggestions$vegetable$treat_window$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pregled in zaščita';
	@override String get body => 'Preglej {subject} in po potrebi zaščiti — najbolje v suhem vremenu.';
}

// Path: suggestions.herbs.start_seedlings
class _Translations$suggestions$herbs$start_seedlings$sl extends Translations$suggestions$herbs$start_seedlings$en {
	_Translations$suggestions$herbs$start_seedlings$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Setev za sadike';
	@override String get body => 'Posej {subject} v zavetju za prednost — do približno {window_end_date}.';
}

// Path: suggestions.herbs.sow_direct
class _Translations$suggestions$herbs$sow_direct$sl extends Translations$suggestions$herbs$sow_direct$en {
	_Translations$suggestions$herbs$sow_direct$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Neposredna setev';
	@override String get body => 'Posej {subject} naravnost na prosto, ko se otopli — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.herbs.plant_out
class _Translations$suggestions$herbs$plant_out$sl extends Translations$suggestions$herbs$plant_out$en {
	_Translations$suggestions$herbs$plant_out$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Saditev na prosto';
	@override String get body => 'Posadi {subject} na prosto, ko mine pozeba — okoli {frost_date}.';
}

// Path: suggestions.tomato.start_seedlings
class _Translations$suggestions$tomato$start_seedlings$sl extends Translations$suggestions$tomato$start_seedlings$en {
	_Translations$suggestions$tomato$start_seedlings$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Setev za sadike';
	@override String get body => 'Posej {subject} v zavetju za prednost — do približno {window_end_date}.';
}

// Path: suggestions.tomato.prick_out
class _Translations$suggestions$tomato$prick_out$sl extends Translations$suggestions$tomato$prick_out$en {
	_Translations$suggestions$tomato$prick_out$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pikiranje';
	@override String get body => 'Od setve {subject} je {days_since} dni — pikiraj sadike v lončke.';
}

// Path: suggestions.tomato.harden_off
class _Translations$suggestions$tomato$harden_off$sl extends Translations$suggestions$tomato$harden_off$en {
	_Translations$suggestions$tomato$harden_off$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Utrjevanje sadik';
	@override String get body => 'Utrdi {subject} na prostem pred saditvijo — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.tomato.transplant
class _Translations$suggestions$tomato$transplant$sl extends Translations$suggestions$tomato$transplant$en {
	_Translations$suggestions$tomato$transplant$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Presaditev';
	@override String get body => '{subject} raste že {days_since} dni — presadi na končno mesto.';
}

// Path: suggestions.tomato.stake
class _Translations$suggestions$tomato$stake$sl extends Translations$suggestions$tomato$stake$en {
	_Translations$suggestions$tomato$stake$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Opora';
	@override String get body => '{subject}: {days_since} dni rasti — dodaj oporo ali kol.';
}

// Path: suggestions.shrub.prune_spring
class _Translations$suggestions$shrub$prune_spring$sl extends Translations$suggestions$shrub$prune_spring$en {
	_Translations$suggestions$shrub$prune_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladanska rez';
	@override String get body => 'Po potrebi obreži {subject} — do približno {window_end_date}.';
}

// Path: suggestions.shrub.overwinter
class _Translations$suggestions$shrub$overwinter$sl extends Translations$suggestions$shrub$overwinter$en {
	_Translations$suggestions$shrub$overwinter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimska zaščita';
	@override String get body => 'Zaščiti {subject} pred prvo močno pozebo — do približno {window_end_date}.';
}

// Path: suggestions.hedge.prune_early_summer
class _Translations$suggestions$hedge$prune_early_summer$sl extends Translations$suggestions$hedge$prune_early_summer$en {
	_Translations$suggestions$hedge$prune_early_summer$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zgodnja poletna rez';
	@override String get body => 'Oblikuj {subject} z rezjo — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.hedge.prune_late_summer
class _Translations$suggestions$hedge$prune_late_summer$sl extends Translations$suggestions$hedge$prune_late_summer$en {
	_Translations$suggestions$hedge$prune_late_summer$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pozna poletna rez';
	@override String get body => 'Pred jesenjo še zadnjič obreži {subject} — do približno {window_end_date}.';
}

// Path: suggestions.conifer.prune
class _Translations$suggestions$conifer$prune$sl extends Translations$suggestions$conifer$prune$en {
	_Translations$suggestions$conifer$prune$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prirez';
	@override String get body => 'Rahlo prireži {subject} v mlado rast — do približno {window_end_date}.';
}

// Path: suggestions.houseplant.repot
class _Translations$suggestions$houseplant$repot$sl extends Translations$suggestions$houseplant$repot$en {
	_Translations$suggestions$houseplant$repot$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Presaditev';
	@override String get body => 'Presadi {subject} ob ponovni rasti — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.houseplant.fertilize_season
class _Translations$suggestions$houseplant$fertilize_season$sl extends Translations$suggestions$houseplant$fertilize_season$en {
	_Translations$suggestions$houseplant$fertilize_season$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dognojevanje';
	@override String get body => 'Med aktivno rastjo gnoji {subject}.';
}

// Path: suggestions.houseplant.overwinter
class _Translations$suggestions$houseplant$overwinter$sl extends Translations$suggestions$houseplant$overwinter$en {
	_Translations$suggestions$houseplant$overwinter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prenesi v zavetje';
	@override String get body => 'Prenesi {subject} v notranjost pred prvo pozebo — do približno {window_end_date}.';
}

// Path: suggestions.blueberry.prune
class _Translations$suggestions$blueberry$prune$sl extends Translations$suggestions$blueberry$prune$en {
	_Translations$suggestions$blueberry$prune$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rez';
	@override String get body => 'Obreži {subject} v mirovanju — do približno {window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_spring
class _Translations$suggestions$cherry_laurel$prune_late_spring$sl extends Translations$suggestions$cherry_laurel$prune_late_spring$en {
	_Translations$suggestions$cherry_laurel$prune_late_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pozna spomladanska rez';
	@override String get body => 'Po prvem poganjku obreži {subject} — okno odprto do ~{window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_summer
class _Translations$suggestions$cherry_laurel$prune_late_summer$sl extends Translations$suggestions$cherry_laurel$prune_late_summer$en {
	_Translations$suggestions$cherry_laurel$prune_late_summer$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pozna poletna rez';
	@override String get body => 'Drugič obreži {subject} — do približno {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_old_wood
class _Translations$suggestions$hydrangea$prune_old_wood$sl extends Translations$suggestions$hydrangea$prune_old_wood$en {
	_Translations$suggestions$hydrangea$prune_old_wood$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rez (stari les)';
	@override String get body => 'Po cvetenju počisti odcvetelo pri {subject} na starem lesu — do približno {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_new_wood
class _Translations$suggestions$hydrangea$prune_new_wood$sl extends Translations$suggestions$hydrangea$prune_new_wood$en {
	_Translations$suggestions$hydrangea$prune_new_wood$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rez (novi les)';
	@override String get body => 'V pozni zimi prikrajšaj {subject} na novem lesu — do približno {window_end_date}.';
}

// Path: suggestions.peach.prune_spring
class _Translations$suggestions$peach$prune_spring$sl extends Translations$suggestions$peach$prune_spring$en {
	_Translations$suggestions$peach$prune_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladanska rez';
	@override String get body => 'Obreži {subject} ob nabrekanju brstov proti kodravosti — do približno {window_end_date}.';
}

// Path: suggestions.raspberry.prune_late_winter
class _Translations$suggestions$raspberry$prune_late_winter$sl extends Translations$suggestions$raspberry$prune_late_winter$en {
	_Translations$suggestions$raspberry$prune_late_winter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pozno zimska rez';
	@override String get body => 'Pred rastjo obreži poganjke pri {subject} — do približno {window_end_date}.';
}

// Path: suggestions.raspberry.prune_after_harvest
class _Translations$suggestions$raspberry$prune_after_harvest$sl extends Translations$suggestions$raspberry$prune_after_harvest$en {
	_Translations$suggestions$raspberry$prune_after_harvest$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rez po obiranju';
	@override String get body => 'Od obiranja {subject} je {days_since} dni — izreži stare poganjke.';
}

// Path: suggestions.rose.prune_spring
class _Translations$suggestions$rose$prune_spring$sl extends Translations$suggestions$rose$prune_spring$en {
	_Translations$suggestions$rose$prune_spring$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spomladanska rez';
	@override String get body => 'Obreži {subject} ob brstenju — do približno {window_end_date}.';
}

// Path: suggestions.rose.overwinter
class _Translations$suggestions$rose$overwinter$sl extends Translations$suggestions$rose$overwinter$en {
	_Translations$suggestions$rose$overwinter$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zimska zaščita';
	@override String get body => 'Pred močno pozebo osuj ali zaščiti {subject} — do približno {window_end_date}.';
}

// Path: suggestions.cucumber.sow_direct
class _Translations$suggestions$cucumber$sow_direct$sl extends Translations$suggestions$cucumber$sow_direct$en {
	_Translations$suggestions$cucumber$sow_direct$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Neposredna setev';
	@override String get body => 'Posej {subject} na prosto, ko je toplo in brez pozebe — okoli {frost_date}.';
}

// Path: suggestions.zucchini.sow_direct
class _Translations$suggestions$zucchini$sow_direct$sl extends Translations$suggestions$zucchini$sow_direct$en {
	_Translations$suggestions$zucchini$sow_direct$sl._(TranslationsSl root) : this._root = root, super.internal(root);

	final TranslationsSl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Neposredna setev';
	@override String get body => 'Posej {subject} na prosto po pozebi — okoli {frost_date}.';
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
			'notif_settings.type_weather_sub' => '»jutri suho — primeren čas«',
			'notif_settings.type_community' => 'Namigi okolice',
			'notif_settings.type_community_sub' => 'kaj počnejo drugi v bližini',
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
			'notif_settings.hints_perm_denied' => 'Obvestila so onemogočena, zato namigov ni mogoče vklopiti.',
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
			'email_login.err_email_domain' => 'Domene tega e-naslova ne najdemo. Preveri naslov.',
			'email_login.did_you_mean' => ({required Object suggestion}) => 'Ste mislili ${suggestion}?',
			'email_login.resend_in' => ({required Object seconds}) => 'Pošlji novo kodo (${seconds} s)',
			'location.title' => 'Kje vrtnariš?',
			'location.why' => 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.',
			'location.use_gps' => 'Uporabi mojo lokacijo',
			'location.enter_place' => 'Vpiši kraj',
			'location.or' => 'ali',
			'location.gps_sub' => 'Samodejno z GPS naprave',
			'location.place_hint' => 'Vas, mesto ali naslov (npr. Šentjur)',
			'location.place_note' => 'Dovolj je vas ali mesto — natančen naslov ni potreben.',
			'location.search' => 'Poišči',
			'location.privacy' => 'Natančne lokacije nikoli ne shranjujemo. Shranimo samo približno okolico (širše območje nekaj km), ki je nikoli ne razkrijemo drugim.',
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
			'location.status_set_at' => ({required Object name}) => 'Lokacija je nastavljena · ${name}',
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
			'areas.type_garden' => 'Vrt',
			'areas.type_lawn' => 'Trata',
			'areas.type_hedge' => 'Živa meja',
			'areas.type_bed' => 'Gredica',
			'areas.type_tree' => 'Sadno drevje',
			'areas.type_ornamental' => 'Okrasno',
			'areas.type_other' => 'Drugo',
			'areas.default_garden_name' => 'Vrt',
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
			'settings.section_suggestions' => 'Predlogi',
			'settings.suggestions_history_sub' => 'Kaj je bilo predlagano in kako si se odzval',
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
			'weather.m_humidity' => 'Vlažnost',
			'weather.m_wind' => 'Veter',
			'weather.m_precipitation' => 'Padavine',
			'weather.m_soil_temp' => 'Temp. tal',
			'weather.m_et0' => 'ET₀',
			'weather.m_rain48h' => 'Dež 48 h',
			'weather.m_no_rain' => 'brez dežja',
			'suggestions.actions.plan' => 'Načrtuj',
			'suggestions.actions.dismiss' => 'Preskoči',
			'suggestions.actions.already_done' => 'Že opravljeno',
			'suggestions.actions.never' => 'Ne predlagaj več',
			'suggestions.actions.remove_subject' => 'Tega nimam več',
			'suggestions.toast.planned' => 'Dodano med opravila',
			'suggestions.toast.logged' => 'Zabeleženo kot opravljeno',
			'suggestions.disclaimer' => 'Predlogi so splošna usmeritev — tvoj vrt najbolje poznaš ti.',
			'suggestions.done_sheet.title' => 'Kdaj je bilo opravljeno?',
			'suggestions.done_sheet.today' => 'Danes',
			'suggestions.done_sheet.yesterday' => 'Včeraj',
			'suggestions.done_sheet.pick' => 'Izberi datum…',
			'suggestions.remove.title' => 'Odstranim?',
			'suggestions.remove.body' => '{subject} odstrani iz vrta in ustavi njegove predloge. Pretekli zapisi ostanejo.',
			'suggestions.remove.confirm' => 'Odstrani',
			'suggestions.history_status.planned' => 'Načrtovano',
			'suggestions.history_status.logged' => 'Zabeleženo',
			'suggestions.history_status.dismissed' => 'Opuščeno',
			'suggestions.history_status.muted' => 'Utišano',
			'suggestions.history_status.missed' => 'Zamujeno',
			'suggestions.band_title' => 'Predlogi zate',
			'suggestions.past_link' => 'Zgodovina',
			'suggestions.past_title' => 'Pretekli predlogi',
			'suggestions.past_intro' => 'Kaj ti je Tendask predlagal in kako si se odzval.',
			'suggestions.past_empty' => 'Še ni zgodovine. Ko se odzoveš na predlog — ga načrtuješ, opustiš ali zabeležiš kot opravljeno — se zapis pojavi tukaj.',
			'suggestions.past_retention' => 'Predloge starejše od enega leta samodejno počistimo.',
			'suggestions.cadence.overdue.title' => '{task} je na vrsti',
			'suggestions.cadence.overdue.body' => '{subject}: zamuda približno {days_overdue} dni (običajni ritem ~{cadence_days} dni).',
			'suggestions.history.anniversary.title' => '{task} — pred letom dni',
			'suggestions.history.anniversary.body' => 'Lani okoli {last_year_date} — {task} pri {subject}. Morda spet?',
			'suggestions.weather.window_open.title' => '{task}: ugodno okno',
			'suggestions.weather.window_open.body' => 'Za {subject} prihaja suho obdobje — primeren čas.',
			'suggestions.community.most_started.title' => '{task} v okolici',
			'suggestions.community.most_started.body' => 'Približno {percent} % vrtnarjev v tvoji okolici je to letos že začelo.',
			'suggestions.lawn.mow_due.title' => 'Čas za košnjo',
			'suggestions.lawn.mow_due.body' => '{subject}: čas za košnjo.',
			'suggestions.lawn.water_drought.title' => 'Zalivanje v suši',
			'suggestions.lawn.water_drought.body' => '{subject} ob suši morda potrebuje zalivanje.',
			'suggestions.lawn.fertilize_spring.title' => 'Spomladansko gnojenje',
			'suggestions.lawn.fertilize_spring.body' => 'Pognoji {subject} za sezono — najbolje do približno {window_end_date}.',
			'suggestions.lawn.fertilize_autumn.title' => 'Jesensko gnojenje',
			'suggestions.lawn.fertilize_autumn.body' => 'Jesensko pognoji {subject} pred zimo — okno odprto do ~{window_end_date}.',
			'suggestions.lawn.lime.title' => 'Apnenje trate',
			'suggestions.lawn.lime.body' => 'Če so tla kisla, apni {subject} — do približno {window_end_date}.',
			'suggestions.lawn.moss_control.title' => 'Zatiranje mahu',
			'suggestions.lawn.moss_control.body' => 'Zatri mah pri {subject} — okno odprto do ~{window_end_date}.',
			'suggestions.lawn.weed_control.title' => 'Zatiranje plevela',
			'suggestions.lawn.weed_control.body' => 'Loti se plevela pri {subject} — najbolje do približno {window_end_date}.',
			'suggestions.lawn.overseed_spring.title' => 'Dosejavanje (pomlad)',
			'suggestions.lawn.overseed_spring.body' => 'Dosej redke dele pri {subject} — do približno {window_end_date}.',
			'suggestions.lawn.overseed_autumn.title' => 'Dosejavanje (jesen)',
			'suggestions.lawn.overseed_autumn.body' => 'Jeseni dosej {subject} — okno odprto do ~{window_end_date}.',
			'suggestions.lawn.scarify_spring.title' => 'Vertikutiranje (pomlad)',
			'suggestions.lawn.scarify_spring.body' => 'Odstrani travni filc pri {subject} — do približno {window_end_date}.',
			'suggestions.lawn.scarify_autumn.title' => 'Vertikutiranje (jesen)',
			'suggestions.lawn.scarify_autumn.body' => 'Jeseni vertikutiraj {subject} — okno odprto do ~{window_end_date}.',
			'suggestions.lawn.aerate.title' => 'Prezračevanje',
			'suggestions.lawn.aerate.body' => 'Prezrači {subject} za manjšo zbitost — do približno {window_end_date}.',
			'suggestions.lawn.roll.title' => 'Valjanje trate',
			'suggestions.lawn.roll.body' => 'Po zimi povaljaj {subject} — okno odprto do ~{window_end_date}.',
			'suggestions.lawn.topdress.title' => 'Nasipavanje',
			'suggestions.lawn.topdress.body' => 'Nasuj in poravnaj {subject} — do približno {window_end_date}.',
			'suggestions.fruit_tree.fertilize_spring.title' => 'Spomladansko gnojenje',
			'suggestions.fruit_tree.fertilize_spring.body' => 'Pognoji {subject} ob začetku rasti — do približno {window_end_date}.',
			'suggestions.fruit_tree.prune_winter.title' => 'Zimska rez',
			'suggestions.fruit_tree.prune_winter.body' => 'Obreži {subject} v mirovanju — okno odprto do ~{window_end_date}.',
			'suggestions.fruit_tree.treat_dormant.title' => 'Zimsko škropljenje',
			'suggestions.fruit_tree.treat_dormant.body' => 'Opravi zimsko škropljenje pri {subject} — do približno {window_end_date}.',
			'suggestions.fruit_tree.mulch.title' => 'Zastiranje',
			'suggestions.fruit_tree.mulch.body' => 'Zastri okolico {subject} za ohranjanje vlage — do približno {window_end_date}.',
			'suggestions.fruit_tree.thin_fruit.title' => 'Redčenje plodov',
			'suggestions.fruit_tree.thin_fruit.body' => 'Razredči plodiče pri {subject} za boljšo velikost — okno odprto do ~{window_end_date}.',
			'suggestions.fruit_tree.graft_spring.title' => 'Spomladansko cepljenje',
			'suggestions.fruit_tree.graft_spring.body' => 'Cepi {subject} ob dvigu soka — do približno {window_end_date}.',
			'suggestions.fruit_tree.graft_budding.title' => 'Poletno okuliranje',
			'suggestions.fruit_tree.graft_budding.body' => 'Okuliraj {subject} v poznem poletju — okno odprto do ~{window_end_date}.',
			'suggestions.berries.prune_winter.title' => 'Zimska rez',
			'suggestions.berries.prune_winter.body' => 'Obreži {subject} v mirovanju — do približno {window_end_date}.',
			'suggestions.berries.fertilize_spring.title' => 'Spomladansko gnojenje',
			'suggestions.berries.fertilize_spring.body' => 'Pognoji {subject} ob začetku rasti — do približno {window_end_date}.',
			_ => null,
		} ?? switch (path) {
			'suggestions.berries.mulch.title' => 'Zastiranje',
			'suggestions.berries.mulch.body' => 'Zastri {subject} za hladne in vlažne korenine — do približno {window_end_date}.',
			'suggestions.berries.treat_dormant.title' => 'Zimsko škropljenje',
			'suggestions.berries.treat_dormant.body' => 'Opravi zimsko škropljenje pri {subject} — do približno {window_end_date}.',
			'suggestions.vegetable.start_seedlings.title' => 'Setev za sadike',
			'suggestions.vegetable.start_seedlings.body' => 'Posej {subject} v zavetju za prednost pred saditvijo — do približno {window_end_date}.',
			'suggestions.vegetable.prick_out.title' => 'Pikiranje',
			'suggestions.vegetable.prick_out.body' => 'Od setve {subject} je {days_since} dni — pikiraj sadike v lončke.',
			'suggestions.vegetable.harden_off.title' => 'Utrjevanje sadik',
			'suggestions.vegetable.harden_off.body' => 'Utrdi {subject} na prostem pred saditvijo — okno odprto do ~{window_end_date}.',
			'suggestions.vegetable.plant_out.title' => 'Saditev na prosto',
			'suggestions.vegetable.plant_out.body' => 'Posadi {subject} na prosto, ko mine pozeba — okoli {frost_date}.',
			'suggestions.vegetable.transplant.title' => 'Presaditev',
			'suggestions.vegetable.transplant.body' => 'Presadi {subject} na končno mesto po pozebi — okoli {frost_date}.',
			'suggestions.vegetable.sow_direct.title' => 'Neposredna setev',
			'suggestions.vegetable.sow_direct.body' => 'Posej {subject} naravnost na prosto, ko se otopli — okno odprto do ~{window_end_date}.',
			'suggestions.vegetable.fertilize_season.title' => 'Dognojevanje',
			'suggestions.vegetable.fertilize_season.body' => 'Med rastno dobo pognoji {subject}.',
			'suggestions.vegetable.treat_window.title' => 'Pregled in zaščita',
			'suggestions.vegetable.treat_window.body' => 'Preglej {subject} in po potrebi zaščiti — najbolje v suhem vremenu.',
			'suggestions.herbs.start_seedlings.title' => 'Setev za sadike',
			'suggestions.herbs.start_seedlings.body' => 'Posej {subject} v zavetju za prednost — do približno {window_end_date}.',
			'suggestions.herbs.sow_direct.title' => 'Neposredna setev',
			'suggestions.herbs.sow_direct.body' => 'Posej {subject} naravnost na prosto, ko se otopli — okno odprto do ~{window_end_date}.',
			'suggestions.herbs.plant_out.title' => 'Saditev na prosto',
			'suggestions.herbs.plant_out.body' => 'Posadi {subject} na prosto, ko mine pozeba — okoli {frost_date}.',
			'suggestions.tomato.start_seedlings.title' => 'Setev za sadike',
			'suggestions.tomato.start_seedlings.body' => 'Posej {subject} v zavetju za prednost — do približno {window_end_date}.',
			'suggestions.tomato.prick_out.title' => 'Pikiranje',
			'suggestions.tomato.prick_out.body' => 'Od setve {subject} je {days_since} dni — pikiraj sadike v lončke.',
			'suggestions.tomato.harden_off.title' => 'Utrjevanje sadik',
			'suggestions.tomato.harden_off.body' => 'Utrdi {subject} na prostem pred saditvijo — okno odprto do ~{window_end_date}.',
			'suggestions.tomato.transplant.title' => 'Presaditev',
			'suggestions.tomato.transplant.body' => '{subject} raste že {days_since} dni — presadi na končno mesto.',
			'suggestions.tomato.stake.title' => 'Opora',
			'suggestions.tomato.stake.body' => '{subject}: {days_since} dni rasti — dodaj oporo ali kol.',
			'suggestions.shrub.prune_spring.title' => 'Spomladanska rez',
			'suggestions.shrub.prune_spring.body' => 'Po potrebi obreži {subject} — do približno {window_end_date}.',
			'suggestions.shrub.overwinter.title' => 'Zimska zaščita',
			'suggestions.shrub.overwinter.body' => 'Zaščiti {subject} pred prvo močno pozebo — do približno {window_end_date}.',
			'suggestions.hedge.prune_early_summer.title' => 'Zgodnja poletna rez',
			'suggestions.hedge.prune_early_summer.body' => 'Oblikuj {subject} z rezjo — okno odprto do ~{window_end_date}.',
			'suggestions.hedge.prune_late_summer.title' => 'Pozna poletna rez',
			'suggestions.hedge.prune_late_summer.body' => 'Pred jesenjo še zadnjič obreži {subject} — do približno {window_end_date}.',
			'suggestions.conifer.prune.title' => 'Prirez',
			'suggestions.conifer.prune.body' => 'Rahlo prireži {subject} v mlado rast — do približno {window_end_date}.',
			'suggestions.houseplant.repot.title' => 'Presaditev',
			'suggestions.houseplant.repot.body' => 'Presadi {subject} ob ponovni rasti — okno odprto do ~{window_end_date}.',
			'suggestions.houseplant.fertilize_season.title' => 'Dognojevanje',
			'suggestions.houseplant.fertilize_season.body' => 'Med aktivno rastjo gnoji {subject}.',
			'suggestions.houseplant.overwinter.title' => 'Prenesi v zavetje',
			'suggestions.houseplant.overwinter.body' => 'Prenesi {subject} v notranjost pred prvo pozebo — do približno {window_end_date}.',
			'suggestions.blueberry.prune.title' => 'Rez',
			'suggestions.blueberry.prune.body' => 'Obreži {subject} v mirovanju — do približno {window_end_date}.',
			'suggestions.cherry_laurel.prune_late_spring.title' => 'Pozna spomladanska rez',
			'suggestions.cherry_laurel.prune_late_spring.body' => 'Po prvem poganjku obreži {subject} — okno odprto do ~{window_end_date}.',
			'suggestions.cherry_laurel.prune_late_summer.title' => 'Pozna poletna rez',
			'suggestions.cherry_laurel.prune_late_summer.body' => 'Drugič obreži {subject} — do približno {window_end_date}.',
			'suggestions.hydrangea.prune_old_wood.title' => 'Rez (stari les)',
			'suggestions.hydrangea.prune_old_wood.body' => 'Po cvetenju počisti odcvetelo pri {subject} na starem lesu — do približno {window_end_date}.',
			'suggestions.hydrangea.prune_new_wood.title' => 'Rez (novi les)',
			'suggestions.hydrangea.prune_new_wood.body' => 'V pozni zimi prikrajšaj {subject} na novem lesu — do približno {window_end_date}.',
			'suggestions.peach.prune_spring.title' => 'Spomladanska rez',
			'suggestions.peach.prune_spring.body' => 'Obreži {subject} ob nabrekanju brstov proti kodravosti — do približno {window_end_date}.',
			'suggestions.raspberry.prune_late_winter.title' => 'Pozno zimska rez',
			'suggestions.raspberry.prune_late_winter.body' => 'Pred rastjo obreži poganjke pri {subject} — do približno {window_end_date}.',
			'suggestions.raspberry.prune_after_harvest.title' => 'Rez po obiranju',
			'suggestions.raspberry.prune_after_harvest.body' => 'Od obiranja {subject} je {days_since} dni — izreži stare poganjke.',
			'suggestions.rose.prune_spring.title' => 'Spomladanska rez',
			'suggestions.rose.prune_spring.body' => 'Obreži {subject} ob brstenju — do približno {window_end_date}.',
			'suggestions.rose.overwinter.title' => 'Zimska zaščita',
			'suggestions.rose.overwinter.body' => 'Pred močno pozebo osuj ali zaščiti {subject} — do približno {window_end_date}.',
			'suggestions.cucumber.sow_direct.title' => 'Neposredna setev',
			'suggestions.cucumber.sow_direct.body' => 'Posej {subject} na prosto, ko je toplo in brez pozebe — okoli {frost_date}.',
			'suggestions.zucchini.sow_direct.title' => 'Neposredna setev',
			'suggestions.zucchini.sow_direct.body' => 'Posej {subject} na prosto po pozebi — okoli {frost_date}.',
			_ => null,
		};
	}
}

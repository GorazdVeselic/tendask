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
	late final Translations$splash$sl splash = Translations$splash$sl.internal(_root);
	late final Translations$nav$sl nav = Translations$nav$sl.internal(_root);
	late final Translations$home$sl home = Translations$home$sl.internal(_root);
	late final Translations$common$sl common = Translations$common$sl.internal(_root);
	late final Translations$notifications$sl notifications = Translations$notifications$sl.internal(_root);
	late final Translations$notif_settings$sl notif_settings = Translations$notif_settings$sl.internal(_root);
	late final Translations$notif_preview$sl notif_preview = Translations$notif_preview$sl.internal(_root);
	late final Translations$onboarding$sl onboarding = Translations$onboarding$sl.internal(_root);
	late final Translations$auth$sl auth = Translations$auth$sl.internal(_root);
	late final Translations$email_login$sl email_login = Translations$email_login$sl.internal(_root);
	late final Translations$location$sl location = Translations$location$sl.internal(_root);
	late final Translations$journal$sl journal = Translations$journal$sl.internal(_root);
	late final Translations$notes$sl notes = Translations$notes$sl.internal(_root);
	late final Translations$task_detail$sl task_detail = Translations$task_detail$sl.internal(_root);
	late final Translations$tasks_list$sl tasks_list = Translations$tasks_list$sl.internal(_root);
	late final Translations$subject_picker$sl subject_picker = Translations$subject_picker$sl.internal(_root);
	late final Translations$entry$sl entry = Translations$entry$sl.internal(_root);
	late final Translations$plant_edit$sl plant_edit = Translations$plant_edit$sl.internal(_root);
	late final Translations$plant_detail$sl plant_detail = Translations$plant_detail$sl.internal(_root);
	late final Translations$area_pick$sl area_pick = Translations$area_pick$sl.internal(_root);
	late final Translations$areas$sl areas = Translations$areas$sl.internal(_root);
	late final Translations$plants$sl plants = Translations$plants$sl.internal(_root);
	late final Translations$supplies$sl supplies = Translations$supplies$sl.internal(_root);
	late final Translations$settings$sl settings = Translations$settings$sl.internal(_root);
	late final Translations$weather$sl weather = Translations$weather$sl.internal(_root);
}

// Path: splash
class Translations$splash$sl {
	Translations$splash$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Tvoj vrtni dnevnik 🌿'
	String get tagline => 'Tvoj vrtni dnevnik 🌿';
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

	/// sl: 'včeraj'
	String get yesterday => 'včeraj';

	/// sl: 'Podatkov ni bilo mogoče naložiti.'
	String get load_error => 'Podatkov ni bilo mogoče naložiti.';
}

// Path: notifications
class Translations$notifications$sl {
	Translations$notifications$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Danes'
	String get today => 'Danes';

	/// sl: 'Jutri'
	String get tomorrow => 'Jutri';
}

// Path: notif_settings
class Translations$notif_settings$sl {
	Translations$notif_settings$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Obvestila'
	String get title => 'Obvestila';

	/// sl: 'Nastavitev ni bilo mogoče naložiti.'
	String get load_error => 'Nastavitev ni bilo mogoče naložiti.';

	/// sl: 'Vrste obvestil'
	String get section_types => 'Vrste obvestil';

	/// sl: 'Opomniki opravil'
	String get type_reminders => 'Opomniki opravil';

	/// sl: 'lokalno · delujejo brez interneta'
	String get type_reminders_sub => 'lokalno · delujejo brez interneta';

	/// sl: 'Pametni namigi (vreme)'
	String get type_weather => 'Pametni namigi (vreme)';

	/// sl: 'kmalu · prek strežnika'
	String get type_weather_sub => 'kmalu · prek strežnika';

	/// sl: 'Namigi okolice'
	String get type_community => 'Namigi okolice';

	/// sl: 'kmalu (V2)'
	String get type_community_sub => 'kmalu (V2)';

	/// sl: 'Privzeti zamik opomnika'
	String get section_default_offset => 'Privzeti zamik opomnika';

	/// sl: 'Predizpolni nova opravila; vedno lahko spremeniš.'
	String get default_offset_hint => 'Predizpolni nova opravila; vedno lahko spremeniš.';

	/// sl: 'Da te ne zasipa'
	String get section_quiet => 'Da te ne zasipa';

	/// sl: 'Tihe ure'
	String get quiet_hours => 'Tihe ure';

	/// sl: '$range brez obvestil'
	String quiet_hours_sub({required Object range}) => '${range} brez obvestil';

	/// sl: 'Največ 1 namig na dan'
	String get frequency_cap => 'Največ 1 namig na dan';

	/// sl: 'vreme in okolico združimo v en povzetek'
	String get frequency_cap_sub => 'vreme in okolico združimo v en povzetek';

	/// sl: 'Več'
	String get section_more => 'Več';

	/// sl: 'Predogled obvestil'
	String get preview => 'Predogled obvestil';

	/// sl: 'kako izgledajo na zaklenjenem zaslonu'
	String get preview_sub => 'kako izgledajo na zaklenjenem zaslonu';

	/// sl: 'Sistemsko dovoljenje'
	String get system_permission => 'Sistemsko dovoljenje';

	/// sl: 'naprava: dovoljeno'
	String get system_permission_on => 'naprava: dovoljeno';

	/// sl: 'točni opomniki niso dovoljeni — tapni za nastavitve'
	String get system_permission_off => 'točni opomniki niso dovoljeni — tapni za nastavitve';
}

// Path: notif_preview
class Translations$notif_preview$sl {
	Translations$notif_preview$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Videz obvestil'
	String get title => 'Videz obvestil';

	/// sl: 'torek, 1. junij'
	String get date => 'torek, 1. junij';

	/// sl: 'zdaj'
	String get rem_now => 'zdaj';

	/// sl: '⏰ Foliarno škropljenje · 07:00'
	String get rem_title => '⏰ Foliarno škropljenje · 07:00';

	/// sl: 'Živa meja + trata · jutro je suho — primeren čas.'
	String get rem_body => 'Živa meja + trata · jutro je suho — primeren čas.';

	/// sl: 'opomnik opravila'
	String get rem_tag => 'opomnik opravila';

	/// sl: 'Jutri zjutraj bo suho ☀️'
	String get wx_title => 'Jutri zjutraj bo suho ☀️';

	/// sl: 'Primeren čas za foliarno škropljenje lovorikovcev.'
	String get wx_body => 'Primeren čas za foliarno škropljenje lovorikovcev.';

	/// sl: 'pametni namig · vreme'
	String get wx_tag => 'pametni namig · vreme';

	/// sl: 'včeraj'
	String get com_yesterday => 'včeraj';

	/// sl: 'Tvoja okolica'
	String get com_title => 'Tvoja okolica';

	/// sl: '68 % vrtnarjev v tvoji okolici je ta teden prvič pognojilo trato.'
	String get com_body => '68 % vrtnarjev v tvoji okolici je ta teden prvič pognojilo trato.';

	/// sl: 'namig okolice · V2'
	String get com_tag => 'namig okolice · V2';

	/// sl: 'Tap na obvestilo odpre ustrezni zaslon (opravilo · namig · okolica).'
	String get footer => 'Tap na obvestilo odpre ustrezni zaslon (opravilo · namig · okolica).';
}

// Path: onboarding
class Translations$onboarding$sl {
	Translations$onboarding$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Preskoči ›'
	String get skip => 'Preskoči ›';

	/// sl: 'Naprej'
	String get next => 'Naprej';

	/// sl: 'Začni 🌿'
	String get start => 'Začni 🌿';

	/// sl: 'kmalu (V2)'
	String get soon_badge => 'kmalu (V2)';

	/// sl: 'Dobrodošel v Tendask'
	String get welcome_title => 'Dobrodošel v Tendask';

	/// sl: 'Tvoj preprost dnevnik za vrt, trato in živo mejo — vsa opravila na enem mestu.'
	String get welcome_body => 'Tvoj preprost dnevnik za vrt, trato in živo mejo — vsa opravila na enem mestu.';

	/// sl: 'Beleži v sekundi'
	String get log_title => 'Beleži v sekundi';

	/// sl: 'Pokosil, zalil, pognojil? Zabeleži kaj, kdaj in kje — z nekaj dotiki. Vreme se shrani samodejno.'
	String get log_body => 'Pokosil, zalil, pognojil? Zabeleži kaj, kdaj in kje — z nekaj dotiki. Vreme se shrani samodejno.';

	/// sl: 'Opomniki + vreme'
	String get remind_title => 'Opomniki + vreme';

	/// sl: 'Načrtuj opravila, prejmi opomnik na telefon in vremenski namig — »jutri zjutraj bo suho, primeren čas za škropljenje«.'
	String get remind_body => 'Načrtuj opravila, prejmi opomnik na telefon in vremenski namig — »jutri zjutraj bo suho, primeren čas za škropljenje«.';

	/// sl: 'Tvoja okolica'
	String get nearby_title => 'Tvoja okolica';

	/// sl: 'Pozneje poglej, kaj počnejo vrtnarji v podobnem podnebju blizu tebe — anonimno in zasebno.'
	String get nearby_body => 'Pozneje poglej, kaj počnejo vrtnarji v podobnem podnebju blizu tebe — anonimno in zasebno.';
}

// Path: auth
class Translations$auth$sl {
	Translations$auth$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Dobrodošel v Tendask'
	String get title => 'Dobrodošel v Tendask';

	/// sl: 'Shrani svoj vrtni dnevnik in ne izgubi zgodovine ob menjavi telefona.'
	String get value_prop => 'Shrani svoj vrtni dnevnik in ne izgubi zgodovine ob menjavi telefona.';

	/// sl: 'Nadaljuj z Apple'
	String get continue_apple => 'Nadaljuj z Apple';

	/// sl: 'Nadaljuj z Google'
	String get continue_google => 'Nadaljuj z Google';

	/// sl: 'Nadaljuj z e-pošto'
	String get continue_email => 'Nadaljuj z e-pošto';

	/// sl: 'Preizkusi brez računa'
	String get guest => 'Preizkusi brez računa';

	/// sl: 'Z e-pošto pošljemo potrditveno kodo (brez gesla). Nadaljevanje pomeni strinjanje s pogoji in zasebnostjo.'
	String get legal => 'Z e-pošto pošljemo potrditveno kodo (brez gesla). Nadaljevanje pomeni strinjanje s pogoji in zasebnostjo.';

	/// sl: 'Brez računa se ob odstranitvi aplikacije ali menjavi naprave vsi podatki izgubijo.'
	String get guest_warning => 'Brez računa se ob odstranitvi aplikacije ali menjavi naprave vsi podatki izgubijo.';

	/// sl: 'Na voljo kmalu.'
	String get coming_soon => 'Na voljo kmalu.';

	/// sl: 'Prijava z Google ni uspela. Poskusi znova.'
	String get google_error => 'Prijava z Google ni uspela. Poskusi znova.';
}

// Path: email_login
class Translations$email_login$sl {
	Translations$email_login$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Prijava z e-pošto'
	String get title => 'Prijava z e-pošto';

	/// sl: 'E-poštni naslov'
	String get email_label => 'E-poštni naslov';

	/// sl: 'ti@primer.si'
	String get email_hint => 'ti@primer.si';

	/// sl: 'Pošlji kodo'
	String get send_code => 'Pošlji kodo';

	/// sl: 'Poslali ti bomo enkratno kodo — brez gesla.'
	String get intro => 'Poslali ti bomo enkratno kodo — brez gesla.';

	/// sl: 'Koda iz e-pošte'
	String get code_label => 'Koda iz e-pošte';

	/// sl: 'Vnesi prejeto kodo'
	String get code_hint => 'Vnesi prejeto kodo';

	/// sl: 'Kodo smo poslali na $email. Vpiši jo spodaj.'
	String code_sent({required Object email}) => 'Kodo smo poslali na ${email}. Vpiši jo spodaj.';

	/// sl: 'Potrdi in se prijavi'
	String get verify => 'Potrdi in se prijavi';

	/// sl: 'Pošlji novo kodo'
	String get resend => 'Pošlji novo kodo';

	/// sl: 'Vpiši veljaven e-poštni naslov.'
	String get err_email => 'Vpiši veljaven e-poštni naslov.';

	/// sl: 'Vpiši kodo iz e-pošte.'
	String get err_code => 'Vpiši kodo iz e-pošte.';

	/// sl: 'Kode ni bilo mogoče poslati. Preveri povezavo in poskusi znova.'
	String get err_send => 'Kode ni bilo mogoče poslati. Preveri povezavo in poskusi znova.';

	/// sl: 'Koda ni pravilna ali je potekla. Poskusi znova.'
	String get err_verify => 'Koda ni pravilna ali je potekla. Poskusi znova.';
}

// Path: location
class Translations$location$sl {
	Translations$location$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Kje vrtnariš?'
	String get title => 'Kje vrtnariš?';

	/// sl: 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.'
	String get why => 'Lokacijo potrebujemo za lokalno vremensko napoved in (kasneje) da ti pokažemo, kaj počnejo vrtnarji v podobnem podnebju.';

	/// sl: 'Uporabi mojo lokacijo'
	String get use_gps => 'Uporabi mojo lokacijo';

	/// sl: 'ali vpiši kraj'
	String get or_enter => 'ali vpiši kraj';

	/// sl: 'Vas, mesto ali naslov (npr. Šentjur)'
	String get place_hint => 'Vas, mesto ali naslov (npr. Šentjur)';

	/// sl: 'Dovolj je vas ali mesto — natančen naslov ni potreben.'
	String get place_note => 'Dovolj je vas ali mesto — natančen naslov ni potreben.';

	/// sl: 'Poišči'
	String get search => 'Poišči';

	/// sl: 'Tvojo lokacijo uporabimo le za približno določitev tvoje okolice (širše območje nekaj kilometrov). Natančna lokacija je shranjena le na tvoji napravi — pri nas hranimo samo okvirno okolico in je nikoli ne razkrijemo drugim.'
	String get privacy => 'Tvojo lokacijo uporabimo le za približno določitev tvoje okolice (širše območje nekaj kilometrov). Natančna lokacija je shranjena le na tvoji napravi — pri nas hranimo samo okvirno okolico in je nikoli ne razkrijemo drugim.';

	/// sl: 'Nadaljuj'
	String get kContinue => 'Nadaljuj';

	/// sl: 'Lokacija je nastavljena.'
	String get set_gps => 'Lokacija je nastavljena.';

	/// sl: 'Lokacija: $name'
	String set_place({required Object name}) => 'Lokacija: ${name}';

	/// sl: 'Dostop do lokacije je zavrnjen. Vpiši kraj ali omogoči dovoljenje v sistemskih nastavitvah.'
	String get err_denied => 'Dostop do lokacije je zavrnjen. Vpiši kraj ali omogoči dovoljenje v sistemskih nastavitvah.';

	/// sl: 'Lokacijske storitve so izklopljene. Vklopi jih ali vpiši kraj.'
	String get err_disabled => 'Lokacijske storitve so izklopljene. Vklopi jih ali vpiši kraj.';

	/// sl: 'Lokacije ni bilo mogoče določiti. Poskusi znova ali vpiši kraj.'
	String get err_unavailable => 'Lokacije ni bilo mogoče določiti. Poskusi znova ali vpiši kraj.';

	/// sl: 'Iskanja ni bilo mogoče izvesti. Preveri povezavo in poskusi znova.'
	String get err_search => 'Iskanja ni bilo mogoče izvesti. Preveri povezavo in poskusi znova.';

	/// sl: 'Za ta kraj ni zadetkov.'
	String get no_results => 'Za ta kraj ni zadetkov.';
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

	/// sl: '(one) {$n opravilo ta mesec} (two) {$n opravili ta mesec} (few) {$n opravila ta mesec} (other) {$n opravil ta mesec}'
	String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: '${n} opravilo ta mesec',
		two: '${n} opravili ta mesec',
		few: '${n} opravila ta mesec',
		other: '${n} opravil ta mesec',
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

	/// sl: '(one) {zamuja 1 dan} (two) {zamuja $n dni} (few) {zamuja $n dni} (other) {zamuja $n dni}'
	String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('sl'))(n,
		one: 'zamuja 1 dan',
		two: 'zamuja ${n} dni',
		few: 'zamuja ${n} dni',
		other: 'zamuja ${n} dni',
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

	/// sl: 'Izberi'
	String get choose => 'Izberi';
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

	/// sl: 'Katero opravilo?'
	String get type_title => 'Katero opravilo?';

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

	/// sl: 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).'
	String get subject_area_note => 'Izberi območje le, kadar opravilo velja za celoto brez posamezne rastline (košnja, mulčenje cele grede).';

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

	/// sl: 'Po meri…'
	String get rem_custom => 'Po meri…';

	/// sl: 'min'
	String get rem_unit_min => 'min';

	/// sl: 'ure'
	String get rem_unit_hour => 'ure';

	/// sl: 'dni'
	String get rem_unit_day => 'dni';

	/// sl: 'ob $t'
	String rem_at({required Object t}) => 'ob ${t}';

	/// sl: 'Ob uri'
	String get rem_choose_time => 'Ob uri';

	/// sl: 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).'
	String get rem_time_note => 'Ura velja pri dnevnih zamikih (npr. »1 dan prej ob 18:00«).';

	/// sl: 'Obvestila so onemogočena, zato opomnika ni mogoče dodati.'
	String get rem_perm_denied => 'Obvestila so onemogočena, zato opomnika ni mogoče dodati.';

	/// sl: 'Dovoli točne opomnike'
	String get rem_exact_title => 'Dovoli točne opomnike';

	/// sl: 'Za sprožitev ob točnem času Tendask potrebuje dovoljenje »Budilke in opomniki«. Vklopi ga v nastavitvah, nato znova dodaj opomnik.'
	String get rem_exact_body => 'Za sprožitev ob točnem času Tendask potrebuje dovoljenje »Budilke in opomniki«. Vklopi ga v nastavitvah, nato znova dodaj opomnik.';

	/// sl: 'Odpri nastavitve'
	String get rem_exact_open => 'Odpri nastavitve';

	/// sl: 'že dodano'
	String get rem_added => 'že dodano';
}

// Path: plant_edit
class Translations$plant_edit$sl {
	Translations$plant_edit$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Uredi rastlino'
	String get title_edit => 'Uredi rastlino';

	/// sl: 'Vrsta'
	String get species => 'Vrsta';

	/// sl: 'Osebno ime (neobvezno)'
	String get alias => 'Osebno ime (neobvezno)';

	/// sl: 'npr. »stara jablana ob ograji«'
	String get alias_hint => 'npr. »stara jablana ob ograji«';

	/// sl: 'Vidiš ga samo ti; prikaže se namesto privzetega imena.'
	String get alias_note => 'Vidiš ga samo ti; prikaže se namesto privzetega imena.';

	/// sl: 'Območje'
	String get location_label => 'Območje';

	/// sl: 'Odstrani rastlino iz vrta'
	String get delete => 'Odstrani rastlino iz vrta';

	/// sl: 'Zgodovina opravil ostane v Dnevniku.'
	String get delete_note => 'Zgodovina opravil ostane v Dnevniku.';

	/// sl: 'Shrani'
	String get save => 'Shrani';
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

	/// sl: 'premakni'
	String get move => 'premakni';

	/// sl: 'Dodeli območje'
	String get assign_area => 'Dodeli območje';
}

// Path: area_pick
class Translations$area_pick$sl {
	Translations$area_pick$sl.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// sl: 'Premakni „${name}“'
	String move_title({required Object name}) => 'Premakni „${name}“';

	/// sl: 'Izberi območje'
	String get choose_title => 'Izberi območje';

	/// sl: 'Rastlina je lahko v enem območju (ali brez). Zgodovina opravil ostane.'
	String get note => 'Rastlina je lahko v enem območju (ali brez). Zgodovina opravil ostane.';

	/// sl: 'Brez območja'
	String get none => 'Brez območja';

	/// sl: 'trenutno'
	String get current => 'trenutno';

	/// sl: 'Novo območje'
	String get new_area => 'Novo območje';

	/// sl: 'Ta rastlina je že v izbranem območju.'
	String get duplicate => 'Ta rastlina je že v izbranem območju.';
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

	/// sl: 'Brez območja'
	String get unassigned => 'Brez območja';

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

	/// sl: 'Rastline'
	String get plants_section => 'Rastline';

	/// sl: 'Dodaj rastlino v $area'
	String add_plant_here({required Object area}) => 'Dodaj rastlino v ${area}';

	/// sl: 'Premakni'
	String get swipe_move => 'Premakni';

	/// sl: 'Odstrani'
	String get swipe_remove => 'Odstrani';

	/// sl: 'Rastline iz tega območja se premaknejo v »Brez območja« (ne izbrišejo se).'
	String get delete_reparent_note => 'Rastline iz tega območja se premaknejo v »Brez območja« (ne izbrišejo se).';

	/// sl: 'Novo območje'
	String get new_area_inline => 'Novo območje';

	/// sl: 'Tvoj vrt je še prazen'
	String get empty_title => 'Tvoj vrt je še prazen';

	/// sl: 'Dodaj rastline, ki jih imaš. Območja (grede, trate) so neobvezna.'
	String get empty_body => 'Dodaj rastline, ki jih imaš. Območja (grede, trate) so neobvezna.';

	/// sl: 'Dodaj rastline'
	String get empty_cta_plant => 'Dodaj rastline';

	/// sl: 'Dodaj območje'
	String get empty_cta_area => 'Dodaj območje';

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

	/// sl: 'Shrani območje'
	String get form_save => 'Shrani območje';

	/// sl: 'Vnesi ime območja.'
	String get err_name => 'Vnesi ime območja.';
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

	/// sl: 'Sobne'
	String get cat_houseplant => 'Sobne';

	/// sl: 'Trata'
	String get cat_lawn => 'Trata';

	/// sl: 'Iz baze'
	String get from_catalog => 'Iz baze';

	/// sl: 'Ne najdeš?'
	String get not_found => 'Ne najdeš?';

	/// sl: '+ Dodaj po meri: »$q«'
	String custom_add({required Object q}) => '+ Dodaj po meri: »${q}«';

	/// sl: 'Lasten vnos je zaseben in se ne deli s skupnostjo.'
	String get custom_private => 'Lasten vnos je zaseben in se ne deli s skupnostjo.';

	/// sl: 'Dodaj rastline'
	String get add_title => 'Dodaj rastline';

	/// sl: 'Pogosto'
	String get frequent => 'Pogosto';

	/// sl: 'Razveljavi'
	String get undo => 'Razveljavi';

	/// sl: 'Končano'
	String get done => 'Končano';

	/// sl: 'Kam dodajam'
	String get add_to_label => 'Kam dodajam';

	/// sl: 'izberi'
	String get choose_area => 'izberi';

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

	/// sl: 'Prijavi se in shrani podatke v oblak'
	String get sign_in_prompt => 'Prijavi se in shrani podatke v oblak';

	/// sl: 'Prijavljen — podatki v oblaku'
	String get signed_in => 'Prijavljen — podatki v oblaku';

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

	/// sl: 'Račun & podatki'
	String get section_account => 'Račun & podatki';

	/// sl: 'Izvozi podatke (GDPR)'
	String get export_data => 'Izvozi podatke (GDPR)';

	/// sl: 'Odjava'
	String get logout => 'Odjava';

	/// sl: 'Odjava?'
	String get logout_confirm_title => 'Odjava?';

	/// sl: 'Odjavi te in počisti lokalne podatke s te naprave. Sinhronizirani podatki ostanejo v oblaku in se vrnejo ob ponovni prijavi z istim računom.'
	String get logout_confirm_body => 'Odjavi te in počisti lokalne podatke s te naprave. Sinhronizirani podatki ostanejo v oblaku in se vrnejo ob ponovni prijavi z istim računom.';

	/// sl: 'Prekliči'
	String get logout_cancel => 'Prekliči';

	/// sl: 'Odjava ni mogoča brez povezave — podatki še niso shranjeni v oblak. Poskusi znova, ko boš povezan.'
	String get logout_offline => 'Odjava ni mogoča brez povezave — podatki še niso shranjeni v oblak. Poskusi znova, ko boš povezan.';

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

	/// sl: 'Tapni za ponovni poskus'
	String get home_retry => 'Tapni za ponovni poskus';
}

/// The flat map containing all translations for locale <sl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
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
			'common.today' => 'Danes',
			'common.yesterday' => 'včeraj',
			'common.load_error' => 'Podatkov ni bilo mogoče naložiti.',
			'notifications.today' => 'Danes',
			'notifications.tomorrow' => 'Jutri',
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
			'auth.coming_soon' => 'Na voljo kmalu.',
			'auth.google_error' => 'Prijava z Google ni uspela. Poskusi znova.',
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
			'areas.swipe_move' => 'Premakni',
			'areas.swipe_remove' => 'Odstrani',
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
			'weather.home_retry' => 'Tapni za ponovni poskus',
			_ => null,
		};
	}
}

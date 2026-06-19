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
class TranslationsDe extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsDe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsDe _root = this; // ignore: unused_field

	@override 
	TranslationsDe $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsDe(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$splash$de splash = _Translations$splash$de._(_root);
	@override late final _Translations$nav$de nav = _Translations$nav$de._(_root);
	@override late final _Translations$home$de home = _Translations$home$de._(_root);
	@override late final _Translations$common$de common = _Translations$common$de._(_root);
	@override late final _Translations$swipe$de swipe = _Translations$swipe$de._(_root);
	@override late final _Translations$notifications$de notifications = _Translations$notifications$de._(_root);
	@override late final _Translations$notif_priming$de notif_priming = _Translations$notif_priming$de._(_root);
	@override late final _Translations$notif_settings$de notif_settings = _Translations$notif_settings$de._(_root);
	@override late final _Translations$notif_preview$de notif_preview = _Translations$notif_preview$de._(_root);
	@override late final _Translations$onboarding$de onboarding = _Translations$onboarding$de._(_root);
	@override late final _Translations$auth$de auth = _Translations$auth$de._(_root);
	@override late final _Translations$email_login$de email_login = _Translations$email_login$de._(_root);
	@override late final _Translations$location$de location = _Translations$location$de._(_root);
	@override late final _Translations$journal$de journal = _Translations$journal$de._(_root);
	@override late final _Translations$notes$de notes = _Translations$notes$de._(_root);
	@override late final _Translations$task_detail$de task_detail = _Translations$task_detail$de._(_root);
	@override late final _Translations$tasks_list$de tasks_list = _Translations$tasks_list$de._(_root);
	@override late final _Translations$subject_picker$de subject_picker = _Translations$subject_picker$de._(_root);
	@override late final _Translations$entry$de entry = _Translations$entry$de._(_root);
	@override late final _Translations$plant_edit$de plant_edit = _Translations$plant_edit$de._(_root);
	@override late final _Translations$plant_detail$de plant_detail = _Translations$plant_detail$de._(_root);
	@override late final _Translations$area_pick$de area_pick = _Translations$area_pick$de._(_root);
	@override late final _Translations$areas$de areas = _Translations$areas$de._(_root);
	@override late final _Translations$plants$de plants = _Translations$plants$de._(_root);
	@override late final _Translations$supplies$de supplies = _Translations$supplies$de._(_root);
	@override late final _Translations$settings$de settings = _Translations$settings$de._(_root);
	@override late final _Translations$weather$de weather = _Translations$weather$de._(_root);
	@override late final _Translations$suggestions$de suggestions = _Translations$suggestions$de._(_root);
}

// Path: splash
class _Translations$splash$de extends Translations$splash$en {
	_Translations$splash$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'Dein Gartentagebuch 🌿';
}

// Path: nav
class _Translations$nav$de extends Translations$nav$en {
	_Translations$nav$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get home => 'Startseite';
	@override String get journal => 'Tagebuch';
	@override String get areas => 'Garten';
	@override String get tasks => 'Aufgaben';
}

// Path: home
class _Translations$home$de extends Translations$home$en {
	_Translations$home$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Guten Tag 🌿';
	@override String get today => 'Heute';
	@override String get recent => 'Zuletzt';
	@override String get no_tasks_today => 'Heute keine geplanten Aufgaben.';
	@override String get no_recent => 'Noch keine erledigten Aufgaben.';
	@override String overdue_banner({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '1 überfällige Aufgabe',
		other: '${n} überfällige Aufgaben',
	);
}

// Path: common
class _Translations$common$de extends Translations$common$en {
	_Translations$common$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get today => 'Heute';
	@override String get yesterday => 'gestern';
	@override String get load_error => 'Daten konnten nicht geladen werden.';
}

// Path: swipe
class _Translations$swipe$de extends Translations$swipe$en {
	_Translations$swipe$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get complete => 'Erledigt';
	@override String get postpone => '+1 Tag';
	@override String get revert => 'Zurück';
	@override String get edit => 'Bearbeiten';
	@override String get move => 'Verschieben';
	@override String get delete => 'Löschen';
}

// Path: notifications
class _Translations$notifications$de extends Translations$notifications$en {
	_Translations$notifications$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get today => 'Heute';
	@override String get tomorrow => 'Morgen';
}

// Path: notif_priming
class _Translations$notif_priming$de extends Translations$notif_priming$en {
	_Translations$notif_priming$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Soll ich dich rechtzeitig erinnern?';
	@override String get why => 'Damit dir keine Aufgabe entgeht — die Erinnerung kommt genau dann, wenn du sie eingestellt hast.';
	@override String get benefit_reminders => 'Aufgaben-Erinnerungen — z. B. „1 Tag vorher um 18:00“.';
	@override String get benefit_weather => 'Smarter Wetter-Hinweis — „morgen trocken, guter Zeitpunkt“. (optional)';
	@override String get benefit_nearby => 'Hinweise aus der Umgebung — was andere in deiner Nähe tun. (V2, optional)';
	@override String get privacy => 'Du kannst jede Art einzeln ein- oder ausschalten, Ruhezeiten festlegen und die Häufigkeit begrenzen. Kein Spam.';
	@override String get enable => 'Benachrichtigungen aktivieren';
	@override String get later => 'Vielleicht später';
}

// Path: notif_settings
class _Translations$notif_settings$de extends Translations$notif_settings$en {
	_Translations$notif_settings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Benachrichtigungen';
	@override String get load_error => 'Einstellungen konnten nicht geladen werden.';
	@override String get section_types => 'Benachrichtigungsarten';
	@override String get type_reminders => 'Aufgaben-Erinnerungen';
	@override String get type_reminders_sub => 'lokal · funktionieren ohne Internet';
	@override String get type_weather => 'Smarte Hinweise (Wetter)';
	@override String get type_weather_sub => '„morgen trocken — ein guter Zeitpunkt“';
	@override String get type_community => 'Hinweise aus der Umgebung';
	@override String get type_community_sub => 'was andere in der Nähe tun';
	@override String get section_default_offset => 'Standard-Vorlaufzeit';
	@override String get default_offset_hint => 'Füllt neue Aufgaben vor; jederzeit änderbar.';
	@override String get section_quiet => 'Damit du nicht überflutet wirst';
	@override String get quiet_hours => 'Ruhezeiten';
	@override String quiet_hours_sub({required Object range}) => '${range}, keine Benachrichtigungen';
	@override String get frequency_cap => 'Höchstens 1 Hinweis pro Tag';
	@override String get frequency_cap_sub => 'Wetter und Umgebung in einer Zusammenfassung';
	@override String get section_more => 'Mehr';
	@override String get preview => 'Benachrichtigungs-Vorschau';
	@override String get preview_sub => 'wie sie auf dem Sperrbildschirm aussehen';
	@override String get system_permission => 'Systemberechtigung';
	@override String get system_permission_on => 'Gerät: erlaubt';
	@override String get system_permission_off => 'exakte Erinnerungen nicht erlaubt — für Einstellungen tippen';
	@override String get hints_perm_denied => 'Benachrichtigungen sind deaktiviert, daher können Hinweise nicht aktiviert werden.';
}

// Path: notif_preview
class _Translations$notif_preview$de extends Translations$notif_preview$en {
	_Translations$notif_preview$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Benachrichtigungen — Vorschau';
	@override String get date => 'Dienstag, 1. Juni';
	@override String get rem_now => 'jetzt';
	@override String get rem_title => '⏰ Blattspritzung · 07:00';
	@override String get rem_body => 'Hecke + Rasen · der Morgen ist trocken — guter Zeitpunkt.';
	@override String get rem_tag => 'Aufgaben-Erinnerung';
	@override String get wx_title => 'Morgen früh wird es trocken ☀️';
	@override String get wx_body => 'Guter Zeitpunkt für die Blattspritzung von Kirschlorbeer.';
	@override String get wx_tag => 'Smarter Hinweis · Wetter';
	@override String get com_yesterday => 'gestern';
	@override String get com_title => 'Deine Umgebung';
	@override String get com_body => '68 % der Gärtner in deiner Nähe haben diese Woche zum ersten Mal den Rasen gedüngt.';
	@override String get com_tag => 'Hinweis aus der Umgebung · V2';
	@override String get footer => 'Ein Tippen auf eine Benachrichtigung öffnet den passenden Bildschirm (Aufgabe · Hinweis · Umgebung).';
}

// Path: onboarding
class _Translations$onboarding$de extends Translations$onboarding$en {
	_Translations$onboarding$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Überspringen ›';
	@override String get next => 'Weiter';
	@override String get start => 'Loslegen 🌿';
	@override String get soon_badge => 'bald (V2)';
	@override String get welcome_title => 'Willkommen bei Tendask';
	@override String get welcome_body => 'Dein einfaches Tagebuch für Garten, Rasen und Hecke — jede Aufgabe an einem Ort.';
	@override String get log_title => 'In Sekunden festhalten';
	@override String get log_body => 'Gemäht, gegossen, gedüngt? Notiere was, wann und wo — mit wenigen Fingertipps. Das Wetter wird automatisch gespeichert.';
	@override String get remind_title => 'Erinnerungen + Wetter';
	@override String get remind_body => 'Plane Aufgaben, erhalte eine Erinnerung auf dein Handy und einen Wetterhinweis — „morgen früh trocken, gute Zeit zum Spritzen“.';
	@override String get nearby_title => 'Deine Umgebung';
	@override String get nearby_body => 'Später: sieh, was Gärtner mit ähnlichem Klima in deiner Nähe tun — anonym und privat.';
}

// Path: auth
class _Translations$auth$de extends Translations$auth$en {
	_Translations$auth$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Willkommen bei Tendask';
	@override String get value_prop => 'Sichere dein Gartentagebuch und verliere deine Historie nicht beim Handywechsel.';
	@override String get continue_apple => 'Mit Apple fortfahren';
	@override String get continue_google => 'Mit Google fortfahren';
	@override String get continue_email => 'Mit E-Mail fortfahren';
	@override String get guest => 'Ohne Konto ausprobieren';
	@override String get legal => 'Wir senden einen Bestätigungscode per E-Mail (ohne Passwort). Mit dem Fortfahren stimmst du den Bedingungen und dem Datenschutz zu.';
	@override String get guest_warning => 'Ohne Konto gehen alle Daten verloren, wenn du die App entfernst oder das Gerät wechselst.';
	@override String get google_error => 'Google-Anmeldung fehlgeschlagen. Bitte versuche es erneut.';
	@override String get coming_soon => 'Demnächst verfügbar.';
	@override String get privacy_link => 'Datenschutzerklärung';
}

// Path: email_login
class _Translations$email_login$de extends Translations$email_login$en {
	_Translations$email_login$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mit E-Mail anmelden';
	@override String get email_label => 'E-Mail-Adresse';
	@override String get email_hint => 'du@beispiel.de';
	@override String get send_code => 'Code senden';
	@override String get intro => 'Wir senden dir einen Einmalcode — ohne Passwort.';
	@override String get code_label => 'Code aus der E-Mail';
	@override String get code_hint => 'Erhaltenen Code eingeben';
	@override String code_sent({required Object email}) => 'Wir haben einen Code an ${email} gesendet. Gib ihn unten ein.';
	@override String get verify => 'Bestätigen und anmelden';
	@override String get resend => 'Neuen Code senden';
	@override String get err_email => 'Gib eine gültige E-Mail-Adresse ein.';
	@override String get err_code => 'Gib den Code aus der E-Mail ein.';
	@override String get err_send => 'Code konnte nicht gesendet werden. Prüfe deine Verbindung und versuche es erneut.';
	@override String get err_verify => 'Der Code ist falsch oder abgelaufen. Versuche es erneut.';
	@override String get err_email_domain => 'Die Domain dieser E-Mail wurde nicht gefunden. Prüfe die Adresse.';
	@override String did_you_mean({required Object suggestion}) => 'Meintest du ${suggestion}?';
	@override String resend_in({required Object seconds}) => 'Neuen Code senden (${seconds} s)';
}

// Path: location
class _Translations$location$de extends Translations$location$en {
	_Translations$location$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wo gärtnerst du?';
	@override String get why => 'Wir brauchen deinen Standort für die lokale Wettervorhersage und (später), um dir zu zeigen, was Gärtner in einem ähnlichen Klima tun.';
	@override String get use_gps => 'Meinen Standort verwenden';
	@override String get enter_place => 'Ort eingeben';
	@override String get or => 'oder';
	@override String get gps_sub => 'Automatisch per Geräte-GPS';
	@override String get place_hint => 'Dorf, Stadt oder Adresse (z. B. Šentjur)';
	@override String get place_note => 'Ein Dorf oder eine Stadt genügt — keine genaue Adresse nötig.';
	@override String get search => 'Suchen';
	@override String get privacy => 'Wir speichern deinen genauen Standort nie. Wir behalten nur eine ungefähre Umgebung (ein größeres Gebiet von wenigen Kilometern), die wir niemals an andere weitergeben.';
	@override String get kContinue => 'Weiter';
	@override String get set_gps => 'Standort festgelegt.';
	@override String set_place({required Object name}) => 'Standort: ${name}';
	@override String get err_denied => 'Standortzugriff verweigert. Gib einen Ort ein oder erlaube den Zugriff in den Systemeinstellungen.';
	@override String get err_disabled => 'Standortdienste sind aus. Schalte sie ein oder gib einen Ort ein.';
	@override String get err_unavailable => 'Standort konnte nicht ermittelt werden. Versuche es erneut oder gib einen Ort ein.';
	@override String get err_search => 'Suche fehlgeschlagen. Prüfe deine Verbindung und versuche es erneut.';
	@override String get no_results => 'Keine Treffer für diesen Ort.';
	@override String get screen_title => 'Gartenstandort';
	@override String get status_set => 'Standort ist festgelegt';
	@override String status_set_at({required Object name}) => 'Standort ist festgelegt · ${name}';
	@override String get status_unset => 'Standort noch nicht festgelegt';
	@override String get clear => 'Standort entfernen';
	@override String get clear_confirm_title => 'Standort entfernen?';
	@override String get clear_confirm_body => 'Das Wetter verwendet die Standardregion, bis du einen neuen Standort festlegst.';
	@override String get clear_confirm_yes => 'Entfernen';
	@override String get clear_confirm_cancel => 'Abbrechen';
	@override String get cleared => 'Standort entfernt';
}

// Path: journal
class _Translations$journal$de extends Translations$journal$en {
	_Translations$journal$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tagebuch';
	@override String get subtitle => 'Gartentagebuch';
	@override String get filter_all => 'Alle';
	@override String get filter_tasks => '✓ Aufgaben';
	@override String get filter_notes => '✍️ Notizen';
	@override String get empty => 'Noch keine Einträge.';
	@override String get empty_tasks => 'Keine erledigten Aufgaben.';
	@override String get empty_notes => 'Noch keine Notizen.';
	@override String get timeline => 'Zeitleiste';
	@override String get month_view => 'Monat';
	@override String get month_hint => '💡 Tippe auf einen Tag, um Aufgaben zu sehen und hinzuzufügen.';
	@override String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} Aufgabe diesen Monat',
		other: '${n} Aufgaben diesen Monat',
	);
	@override String get day_empty => 'Keine Aufgaben an diesem Tag.';
	@override String get day_add => 'Aufgabe an diesem Tag hinzufügen';
}

// Path: notes
class _Translations$notes$de extends Translations$notes$en {
	_Translations$notes$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Neue Notiz';
	@override String get title_edit => 'Notiz bearbeiten';
	@override String get content_label => 'Notiz';
	@override String get content_hint => 'Freier Text — Beobachtung, Idee, Gedanke…';
	@override String get when => 'Wann';
	@override String get today => 'Heute';
	@override String get yesterday => 'Gestern';
	@override String get pick_date => 'Datum…';
	@override String get area => 'Bereich (optional)';
	@override String get no_areas => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.';
	@override String get plant => 'Pflanze (optional)';
	@override String get save => 'Notiz speichern';
	@override String get err_content => 'Notiztext eingeben.';
	@override String get delete => 'Notiz löschen';
	@override String get delete_confirm => 'Diese Aktion kann nicht rückgängig gemacht werden.';
	@override String get info => '🌧️ Das Wetter wird automatisch gespeichert.';
}

// Path: task_detail
class _Translations$task_detail$de extends Translations$task_detail$en {
	_Translations$task_detail$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get section_weather => 'Wetteraufnahme';
	@override String get section_details => 'Details';
	@override String get label_supplies => 'Mittel';
	@override String get label_reminder => 'Erinnerung';
	@override String get label_recurrence => 'Wiederholung';
	@override String get label_note => 'Notiz';
	@override String get badge_waiting => 'Geplant';
	@override String get badge_done => 'Erledigt';
	@override String get action_complete => '✓  Als erledigt markieren';
	@override String get action_postpone => '+1 Tag';
	@override String get action_edit => 'Bearbeiten';
	@override String get action_duplicate => 'Duplizieren';
	@override String get action_delete => 'Löschen';
	@override String get action_revert => 'Zurück auf Ausstehend';
	@override String get action_move => 'Verschieben';
	@override String get recurrence_once => 'Einmalig';
	@override String get recurrence_weekly => 'Wöchentlich';
	@override String get recurrence_seasonal => 'Saisonal';
	@override String get none => '—';
	@override String get not_found => 'Aufgabe nicht gefunden.';
}

// Path: tasks_list
class _Translations$tasks_list$de extends Translations$tasks_list$en {
	_Translations$tasks_list$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aufgaben';
	@override String get subtitle => 'bevorstehende und überfällige';
	@override String get section_overdue => 'Überfällig';
	@override String get section_today => 'Heute';
	@override String get section_tomorrow => 'Morgen';
	@override String get section_this_week => 'Diese Woche';
	@override String get section_later => 'Später';
	@override String get empty => 'Keine offenen Aufgaben. Mit + hinzufügen.';
	@override String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '1 Tag überfällig',
		other: '${n} Tage überfällig',
	);
	@override String get status_today => 'heute';
	@override String get status_tomorrow => 'morgen';
	@override String get action_complete => 'Erledigt';
	@override String get action_postpone => '+1 Tag';
	@override String get action_edit => 'Bearbeiten';
	@override String get action_duplicate => 'Duplizieren';
	@override String get action_delete => 'Löschen';
	@override String get delete_confirm_title => 'Aufgabe löschen?';
	@override String get delete_confirm_body => 'Diese Aktion kann nicht rückgängig gemacht werden.';
	@override String get delete_yes => 'Löschen';
	@override String get delete_cancel => 'Abbrechen';
}

// Path: subject_picker
class _Translations$subject_picker$de extends Translations$subject_picker$en {
	_Translations$subject_picker$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pflanze oder Bereich';
	@override String get choose => 'Wählen';
}

// Path: entry
class _Translations$entry$de extends Translations$entry$en {
	_Translations$entry$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Neue Aufgabe';
	@override String get title_review => 'Überprüfen';
	@override String get kContinue => 'Weiter';
	@override String get skip => 'Überspringen';
	@override String get save => 'Aufgabe speichern';
	@override String get step => 'Schritt';
	@override String get note_card_title => 'Nur eine Notiz, keine Aufgabe?';
	@override String get note_card_action => 'Notiz ›';
	@override String get repeat_last => 'Letztes wiederholen';
	@override String get type_title => 'Welche Aufgabe?';
	@override String get type_hint => 'Ein Tipp auf eine Aufgabe bringt dich automatisch weiter.';
	@override String type_show_all({required Object n}) => 'Alle anzeigen (${n})';
	@override String get type_show_less => 'Weniger anzeigen';
	@override String get subject_title => 'Wofür?';
	@override String get subject_search_hint => 'Pflanze suchen…';
	@override String get subject_plants => 'Pflanzen';
	@override String get subject_add_plant => 'Pflanze hinzufügen';
	@override String get subject_add_area => 'Bereich hinzufügen';
	@override String get subject_from_catalog => 'Aus Katalog hinzufügen';
	@override String get subject_areas_context => 'Bereiche:';
	@override String get subject_area_section => 'Oder der ganze Bereich';
	@override String get subject_area_note => 'Wähle einen Bereich nur, wenn die Aufgabe für das Ganze ohne einzelne Pflanze gilt (Mähen, ein ganzes Beet mulchen).';
	@override String get when_title => 'Wann';
	@override String get when_today => 'Heute';
	@override String get when_tomorrow => 'Morgen';
	@override String get when_pick_date => 'Datum…';
	@override String get when_date => 'Datum';
	@override String get when_time => 'Uhrzeit';
	@override String get when_default_note => 'Standard: heute zur nächsten vollen Stunde.';
	@override String get when_status => 'Status';
	@override String get when_status_waiting => 'Wartet';
	@override String get when_status_done => 'Erledigt';
	@override String get when_status_note => 'Standard aus Datum und Uhrzeit: Zukunft = wartet, sonst = erledigt.';
	@override String get reminder_title => 'Erinnerung';
	@override String get optional => '(optional)';
	@override String get reminder_why => 'Dieser Schritt ist da, weil die Aufgabe geplant ist (Wartet). Eine Erinnerung benachrichtigt dich zur gewählten Zeit auf dem Handy.';
	@override String get reminder_add => 'Erinnerung hinzufügen';
	@override String get reminder_note => 'Einstellbarer Vorlauf und Uhrzeit. Mehrere Erinnerungen pro Aufgabe.';
	@override String get supplies_title => 'Mittel';
	@override String get supplies_why => 'Dieser Schritt ist da, weil die Aufgabe normalerweise Mittel verbraucht. Sie werden vom Bestand abgezogen.';
	@override String get supplies_add => 'Mittel aus Bestand hinzufügen';
	@override String get supplies_note => 'Eine Mischung für alle gewählten Pflanzen — einmal abgezogen.';
	@override String get review_title => 'Überprüfen — tippe eine Zeile zum Bearbeiten';
	@override String get review_type => 'Aufgabe';
	@override String get review_subject => 'Wofür';
	@override String get review_when => 'Wann';
	@override String get review_reminder => 'Erinnerung';
	@override String get review_supplies => 'Mittel';
	@override String get review_fix => 'Bearbeiten';
	@override String get review_none => '—';
	@override String get note_label => 'Notiz';
	@override String get note_hint => 'z. B. morgens vor angesagtem Regen';
	@override String get weather_note => '🌧️ Das Wetter wird beim Abschluss automatisch gespeichert.';
	@override String get err_subject => 'Wähle mindestens eine Pflanze oder einen Bereich.';
	@override String get rem_event => 'Zum Zeitpunkt';
	@override String get rem_10min => '10 Minuten vorher';
	@override String get rem_1hour => '1 Stunde vorher';
	@override String get rem_1day => '1 Tag vorher';
	@override String get rem_2day => '2 Tage vorher';
	@override String get rem_custom => 'Eigene…';
	@override String get rem_unit_min => 'Min';
	@override String get rem_unit_hour => 'Std';
	@override String get rem_unit_day => 'Tage';
	@override String get rem_custom_label => 'Wie lange vorher?';
	@override String get rem_before => 'vorher';
	@override String rem_at({required Object t}) => 'um ${t}';
	@override String get rem_choose_time => 'Um Uhrzeit';
	@override String get rem_time_note => 'Die Uhrzeit gilt bei tagbasiertem Vorlauf (z. B. „1 Tag vorher um 18:00“).';
	@override String get rem_perm_denied => 'Benachrichtigungen sind deaktiviert, daher kann keine Erinnerung hinzugefügt werden.';
	@override String get rem_exact_title => 'Exakte Erinnerungen erlauben';
	@override String get rem_exact_body => 'Damit sie zur exakten Zeit ausgelöst wird, benötigt Tendask die Berechtigung „Wecker und Erinnerungen“. Aktiviere sie in den Einstellungen und füge die Erinnerung erneut hinzu.';
	@override String get rem_exact_open => 'Einstellungen öffnen';
	@override String get rem_added => 'bereits hinzugefügt';
}

// Path: plant_edit
class _Translations$plant_edit$de extends Translations$plant_edit$en {
	_Translations$plant_edit$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title_edit => 'Pflanze bearbeiten';
	@override String get species => 'Art';
	@override String get alias => 'Eigener Name (optional)';
	@override String get alias_hint => 'z. B. „alter Apfel am Zaun“';
	@override String get alias_note => 'Nur du siehst ihn; wird statt des Standardnamens angezeigt.';
	@override String get location_label => 'Bereich';
	@override String get delete => 'Pflanze aus dem Garten entfernen';
	@override String get delete_note => 'Der Aufgabenverlauf bleibt im Tagebuch.';
	@override String get save => 'Speichern';
}

// Path: plant_detail
class _Translations$plant_detail$de extends Translations$plant_detail$en {
	_Translations$plant_detail$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get not_found => 'Pflanze nicht gefunden.';
	@override String get history_title => 'Aufgabenverlauf';
	@override String get history_empty => 'Noch keine Aufgaben für diese Pflanze.';
	@override String get move => 'verschieben';
	@override String get assign_area => 'Bereich zuweisen';
}

// Path: area_pick
class _Translations$area_pick$de extends Translations$area_pick$en {
	_Translations$area_pick$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String move_title({required Object name}) => '„${name}“ verschieben';
	@override String get choose_title => 'Bereich wählen';
	@override String get note => 'Eine Pflanze gehört zu einem Bereich (oder keinem). Der Aufgabenverlauf bleibt.';
	@override String get none => 'Kein Bereich';
	@override String get current => 'aktuell';
	@override String get new_area => 'Neuer Bereich';
	@override String get duplicate => 'Diese Pflanze ist bereits im gewählten Bereich.';
}

// Path: areas
class _Translations$areas$de extends Translations$areas$en {
	_Translations$areas$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Garten';
	@override String get subtitle => 'Pflanzen und Rasen';
	@override String get unassigned => 'Ohne Bereich';
	@override String get last_prefix => 'zuletzt:';
	@override String get type_garden => 'Garten';
	@override String get type_lawn => 'Rasen';
	@override String get type_hedge => 'Hecke';
	@override String get type_bed => 'Beet';
	@override String get type_tree => 'Obstbaum';
	@override String get type_ornamental => 'Zierpflanzen';
	@override String get type_other => 'Sonstiges';
	@override String get default_garden_name => 'Garten';
	@override String get history_title => 'Aufgabenverlauf';
	@override String get history_empty => 'Noch keine Aufgaben in diesem Bereich.';
	@override String get plants_section => 'Pflanzen';
	@override String add_plant_here({required Object area}) => 'Pflanze zu ${area} hinzufügen';
	@override String get delete_reparent_note => 'Pflanzen in diesem Bereich wechseln zu „Ohne Bereich“ (sie werden nicht gelöscht).';
	@override String get new_area_inline => 'Neuer Bereich';
	@override String get empty_title => 'Dein Garten ist leer';
	@override String get empty_body => 'Füge deine Pflanzen hinzu. Bereiche (Beete, Rasen) sind optional.';
	@override String get empty_cta_plant => 'Pflanzen hinzufügen';
	@override String get empty_cta_area => 'Bereich hinzufügen';
	@override String get action_edit => 'Bearbeiten';
	@override String get action_delete => 'Löschen';
	@override String get delete_confirm_title => 'Bereich löschen?';
	@override String get delete_confirm_body => 'Aufgaben bleiben erhalten, verlieren aber die Verknüpfung zum Bereich.';
	@override String get form_title_new => 'Neuer Bereich';
	@override String get form_title_edit => 'Bereich bearbeiten';
	@override String get form_name => 'Name';
	@override String get form_name_hint => 'z. B. Hochbeet 1';
	@override String get form_type => 'Typ';
	@override String get form_save => 'Bereich speichern';
	@override String get err_name => 'Bereichsnamen eingeben.';
}

// Path: plants
class _Translations$plants$de extends Translations$plants$en {
	_Translations$plants$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get picker_title => 'Pflanze auswählen';
	@override String get search_hint => 'Pflanze suchen…';
	@override String get cat_all => 'Alle';
	@override String get cat_fruit_tree => 'Obstbäume';
	@override String get cat_berries => 'Beeren';
	@override String get cat_vegetable => 'Gemüse';
	@override String get cat_herbs => 'Kräuter';
	@override String get cat_ornamental => 'Zierpflanzen';
	@override String get cat_houseplant => 'Zimmerpflanzen';
	@override String get cat_lawn => 'Rasen';
	@override String get from_catalog => 'Aus dem Katalog';
	@override String get not_found => 'Nicht gefunden?';
	@override String custom_add({required Object q}) => '+ Eigene hinzufügen: „${q}“';
	@override String get custom_private => 'Ein eigener Eintrag ist privat und wird nicht mit der Community geteilt.';
	@override String get add_title => 'Pflanzen hinzufügen';
	@override String get frequent => 'Häufig';
	@override String get undo => 'Rückgängig';
	@override String get done => 'Fertig';
	@override String get add_to_label => 'Hinzufügen zu';
	@override String get choose_area => 'wählen';
	@override String get field_add => 'Pflanze auswählen';
	@override String get field_empty => 'Dieser Bereich hat noch keine Pflanzen. Füge unten eine hinzu.';
}

// Path: supplies
class _Translations$supplies$de extends Translations$supplies$en {
	_Translations$supplies$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vorräte';
	@override String get subtitle => 'was ich zu Hause habe';
	@override String get empty => 'Noch keine Vorräte. Füge welche mit + hinzu.';
	@override String get low => 'wenig';
	@override String qty({required Object q, required Object unit}) => '~${q}${unit}';
	@override String get form_new => 'Neues Mittel';
	@override String get form_edit => 'Mittel bearbeiten';
	@override String get form_name => 'Name';
	@override String get form_quantity => 'Menge';
	@override String get form_unit => 'Einheit';
	@override String get form_threshold => 'Warnen bei (Schwelle)';
	@override String get form_save => 'Speichern';
	@override String get err_name => 'Namen des Mittels eingeben.';
	@override String get add_to_task => 'Mittel hinzufügen';
	@override String get pick_new => 'Neues Mittel';
	@override String get amount => 'Verbrauchte Menge';
	@override String get add_confirm => 'Hinzufügen';
}

// Path: settings
class _Translations$settings$de extends Translations$settings$en {
	_Translations$settings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Einstellungen';
	@override String get profile_guest => 'Gast (nicht angemeldet)';
	@override String get sign_in_prompt => 'Melde dich an, um deine Daten zu sichern';
	@override String get signed_in => 'Angemeldet — Daten gesichert';
	@override String get section_location => 'Standort';
	@override String get location_placeholder => 'Wetter-Standort';
	@override String get section_language => 'Sprache';
	@override String get section_notifications => 'Benachrichtigungen';
	@override String get notifications_placeholder => 'Benachrichtigungen und Erinnerungen';
	@override String get section_suggestions => 'Vorschläge';
	@override String get suggestions_history_sub => 'Was vorgeschlagen wurde und wie du reagiert hast';
	@override String get section_garden => 'Garten';
	@override String get supplies => '📦 Vorräte & Mittel';
	@override String get supplies_sub => 'Harnstoff, Algen, Dünger, Geräte';
	@override String get section_account => 'Konto & Daten';
	@override String get export_data => 'Daten exportieren (DSGVO)';
	@override String get logout => 'Abmelden';
	@override String get logout_confirm_title => 'Abmelden?';
	@override String get logout_confirm_body => 'Meldet dich ab und löscht lokale Daten von diesem Gerät. Synchronisierte Daten bleiben in der Cloud und kehren zurück, wenn du dich mit demselben Konto erneut anmeldest.';
	@override String get logout_cancel => 'Abbrechen';
	@override String get logout_offline => 'Abmelden offline nicht möglich — deine Daten sind noch nicht in der Cloud gesichert. Versuche es erneut, sobald du verbunden bist.';
	@override String get export_share_text => 'Tendask Datenexport';
	@override String get export_error => 'Export fehlgeschlagen. Bitte versuche es erneut.';
	@override String get delete_account => 'Konto und alle Daten löschen';
	@override String get delete_account_confirm_title => 'Konto löschen?';
	@override String get delete_account_confirm_body => 'Löscht dein Konto und alle Daten (Aufgaben, Bereiche, Pflanzen, Notizen) endgültig — sowohl in der Cloud als auch auf diesem Gerät. Dies kann nicht rückgängig gemacht werden.';
	@override String get delete_account_confirm => 'Konto löschen';
	@override String get delete_account_error => 'Löschen fehlgeschlagen. Versuche es erneut, sobald du verbunden bist.';
	@override String get delete_data => 'Alle Daten auf diesem Gerät löschen';
	@override String get delete_data_confirm_title => 'Alle Daten löschen?';
	@override String get delete_data_confirm_body => 'Löscht alle Daten auf diesem Gerät (Aufgaben, Bereiche, Pflanzen, Notizen) endgültig. Dies kann nicht rückgängig gemacht werden.';
	@override String get delete_data_confirm => 'Löschen';
	@override String get section_about => 'Über';
	@override String get privacy_policy => 'Datenschutzerklärung';
}

// Path: weather
class _Translations$weather$de extends Translations$weather$en {
	_Translations$weather$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get cond_clear => 'Klar';
	@override String get cond_mainly_clear => 'Überwiegend klar';
	@override String get cond_cloudy => 'Bewölkt';
	@override String get cond_fog => 'Nebel';
	@override String get cond_drizzle => 'Nieselregen';
	@override String get cond_rain => 'Regen';
	@override String get cond_snow => 'Schnee';
	@override String get cond_showers => 'Schauer';
	@override String get cond_thunderstorm => 'Gewitter';
	@override String get cond_unknown => '—';
	@override String get band_forecast => 'Vorhersage';
	@override String get rain_past48h => 'Regen letzte 48 h:';
	@override String get detail_waiting => 'Das Wetter wird erfasst, sobald du die Aufgabe als erledigt markierst.';
	@override String get detail_none => 'Keine Wetteraufnahme (zum Zeitpunkt offline).';
	@override String get home_unavailable => 'Wetter derzeit nicht verfügbar.';
	@override String get home_retry => 'Zum Wiederholen tippen';
	@override String get loading => 'Wetter wird geladen…';
	@override String updated_at({required Object time}) => 'Aktualisiert ${time}';
	@override String get m_humidity => 'Luftfeuchte';
	@override String get m_wind => 'Wind';
	@override String get m_precipitation => 'Niederschlag';
	@override String get m_soil_temp => 'Bodentemp.';
	@override String get m_et0 => 'ET₀';
	@override String get m_rain48h => 'Regen 48 h';
	@override String get m_no_rain => 'kein Regen';
}

// Path: suggestions
class _Translations$suggestions$de extends Translations$suggestions$en {
	_Translations$suggestions$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$actions$de actions = _Translations$suggestions$actions$de._(_root);
	@override late final _Translations$suggestions$toast$de toast = _Translations$suggestions$toast$de._(_root);
	@override String get disclaimer => 'Vorschläge sind allgemeine Hinweise — deinen Garten kennst du am besten.';
	@override late final _Translations$suggestions$done_sheet$de done_sheet = _Translations$suggestions$done_sheet$de._(_root);
	@override late final _Translations$suggestions$remove$de remove = _Translations$suggestions$remove$de._(_root);
	@override late final _Translations$suggestions$history_status$de history_status = _Translations$suggestions$history_status$de._(_root);
	@override String get band_title => 'Vorschläge für dich';
	@override String get past_link => 'Verlauf';
	@override String get past_title => 'Frühere Vorschläge';
	@override String get past_intro => 'Was Tendask vorgeschlagen hat und wie du reagiert hast.';
	@override String get past_empty => 'Noch kein Verlauf. Sobald du auf einen Vorschlag reagierst — einplanen, überspringen oder als erledigt erfassen — erscheint er hier.';
	@override String get past_retention => 'Vorschläge, die älter als ein Jahr sind, werden automatisch entfernt.';
	@override late final _Translations$suggestions$cadence$de cadence = _Translations$suggestions$cadence$de._(_root);
	@override late final _Translations$suggestions$history$de history = _Translations$suggestions$history$de._(_root);
	@override late final _Translations$suggestions$weather$de weather = _Translations$suggestions$weather$de._(_root);
	@override late final _Translations$suggestions$community$de community = _Translations$suggestions$community$de._(_root);
	@override late final _Translations$suggestions$lawn$de lawn = _Translations$suggestions$lawn$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$de fruit_tree = _Translations$suggestions$fruit_tree$de._(_root);
	@override late final _Translations$suggestions$berries$de berries = _Translations$suggestions$berries$de._(_root);
	@override late final _Translations$suggestions$vegetable$de vegetable = _Translations$suggestions$vegetable$de._(_root);
	@override late final _Translations$suggestions$herbs$de herbs = _Translations$suggestions$herbs$de._(_root);
	@override late final _Translations$suggestions$tomato$de tomato = _Translations$suggestions$tomato$de._(_root);
	@override late final _Translations$suggestions$shrub$de shrub = _Translations$suggestions$shrub$de._(_root);
	@override late final _Translations$suggestions$hedge$de hedge = _Translations$suggestions$hedge$de._(_root);
	@override late final _Translations$suggestions$conifer$de conifer = _Translations$suggestions$conifer$de._(_root);
	@override late final _Translations$suggestions$houseplant$de houseplant = _Translations$suggestions$houseplant$de._(_root);
	@override late final _Translations$suggestions$blueberry$de blueberry = _Translations$suggestions$blueberry$de._(_root);
	@override late final _Translations$suggestions$cherry_laurel$de cherry_laurel = _Translations$suggestions$cherry_laurel$de._(_root);
	@override late final _Translations$suggestions$hydrangea$de hydrangea = _Translations$suggestions$hydrangea$de._(_root);
	@override late final _Translations$suggestions$peach$de peach = _Translations$suggestions$peach$de._(_root);
	@override late final _Translations$suggestions$raspberry$de raspberry = _Translations$suggestions$raspberry$de._(_root);
	@override late final _Translations$suggestions$rose$de rose = _Translations$suggestions$rose$de._(_root);
	@override late final _Translations$suggestions$cucumber$de cucumber = _Translations$suggestions$cucumber$de._(_root);
	@override late final _Translations$suggestions$zucchini$de zucchini = _Translations$suggestions$zucchini$de._(_root);
}

// Path: suggestions.actions
class _Translations$suggestions$actions$de extends Translations$suggestions$actions$en {
	_Translations$suggestions$actions$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get plan => 'Einplanen';
	@override String get dismiss => 'Überspringen';
	@override String get already_done => 'Schon erledigt';
	@override String get never => 'Nicht mehr vorschlagen';
	@override String get remove_subject => 'Habe ich nicht mehr';
}

// Path: suggestions.toast
class _Translations$suggestions$toast$de extends Translations$suggestions$toast$en {
	_Translations$suggestions$toast$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get planned => 'Zu deinen Aufgaben hinzugefügt';
	@override String get logged => 'Als erledigt erfasst';
}

// Path: suggestions.done_sheet
class _Translations$suggestions$done_sheet$de extends Translations$suggestions$done_sheet$en {
	_Translations$suggestions$done_sheet$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wann hast du es gemacht?';
	@override String get today => 'Heute';
	@override String get yesterday => 'Gestern';
	@override String get pick => 'Datum wählen…';
}

// Path: suggestions.remove
class _Translations$suggestions$remove$de extends Translations$suggestions$remove$en {
	_Translations$suggestions$remove$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Entfernen?';
	@override String get body => 'Entfernt {subject} aus deinem Garten und stoppt die Vorschläge dazu. Deine bisherigen Einträge bleiben.';
	@override String get confirm => 'Entfernen';
}

// Path: suggestions.history_status
class _Translations$suggestions$history_status$de extends Translations$suggestions$history_status$en {
	_Translations$suggestions$history_status$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get planned => 'Eingeplant';
	@override String get logged => 'Erfasst';
	@override String get dismissed => 'Verworfen';
	@override String get muted => 'Stumm';
	@override String get missed => 'Verpasst';
}

// Path: suggestions.cadence
class _Translations$suggestions$cadence$de extends Translations$suggestions$cadence$en {
	_Translations$suggestions$cadence$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cadence$overdue$de overdue = _Translations$suggestions$cadence$overdue$de._(_root);
}

// Path: suggestions.history
class _Translations$suggestions$history$de extends Translations$suggestions$history$en {
	_Translations$suggestions$history$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$history$anniversary$de anniversary = _Translations$suggestions$history$anniversary$de._(_root);
}

// Path: suggestions.weather
class _Translations$suggestions$weather$de extends Translations$suggestions$weather$en {
	_Translations$suggestions$weather$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$weather$window_open$de window_open = _Translations$suggestions$weather$window_open$de._(_root);
}

// Path: suggestions.community
class _Translations$suggestions$community$de extends Translations$suggestions$community$en {
	_Translations$suggestions$community$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$community$most_started$de most_started = _Translations$suggestions$community$most_started$de._(_root);
}

// Path: suggestions.lawn
class _Translations$suggestions$lawn$de extends Translations$suggestions$lawn$en {
	_Translations$suggestions$lawn$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$lawn$mow_due$de mow_due = _Translations$suggestions$lawn$mow_due$de._(_root);
	@override late final _Translations$suggestions$lawn$water_drought$de water_drought = _Translations$suggestions$lawn$water_drought$de._(_root);
	@override late final _Translations$suggestions$lawn$fertilize_spring$de fertilize_spring = _Translations$suggestions$lawn$fertilize_spring$de._(_root);
	@override late final _Translations$suggestions$lawn$fertilize_autumn$de fertilize_autumn = _Translations$suggestions$lawn$fertilize_autumn$de._(_root);
	@override late final _Translations$suggestions$lawn$lime$de lime = _Translations$suggestions$lawn$lime$de._(_root);
	@override late final _Translations$suggestions$lawn$moss_control$de moss_control = _Translations$suggestions$lawn$moss_control$de._(_root);
	@override late final _Translations$suggestions$lawn$weed_control$de weed_control = _Translations$suggestions$lawn$weed_control$de._(_root);
	@override late final _Translations$suggestions$lawn$overseed_spring$de overseed_spring = _Translations$suggestions$lawn$overseed_spring$de._(_root);
	@override late final _Translations$suggestions$lawn$overseed_autumn$de overseed_autumn = _Translations$suggestions$lawn$overseed_autumn$de._(_root);
	@override late final _Translations$suggestions$lawn$scarify_spring$de scarify_spring = _Translations$suggestions$lawn$scarify_spring$de._(_root);
	@override late final _Translations$suggestions$lawn$scarify_autumn$de scarify_autumn = _Translations$suggestions$lawn$scarify_autumn$de._(_root);
	@override late final _Translations$suggestions$lawn$aerate$de aerate = _Translations$suggestions$lawn$aerate$de._(_root);
	@override late final _Translations$suggestions$lawn$roll$de roll = _Translations$suggestions$lawn$roll$de._(_root);
	@override late final _Translations$suggestions$lawn$topdress$de topdress = _Translations$suggestions$lawn$topdress$de._(_root);
}

// Path: suggestions.fruit_tree
class _Translations$suggestions$fruit_tree$de extends Translations$suggestions$fruit_tree$en {
	_Translations$suggestions$fruit_tree$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$fruit_tree$fertilize_spring$de fertilize_spring = _Translations$suggestions$fruit_tree$fertilize_spring$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$prune_winter$de prune_winter = _Translations$suggestions$fruit_tree$prune_winter$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$treat_dormant$de treat_dormant = _Translations$suggestions$fruit_tree$treat_dormant$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$mulch$de mulch = _Translations$suggestions$fruit_tree$mulch$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$thin_fruit$de thin_fruit = _Translations$suggestions$fruit_tree$thin_fruit$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$graft_spring$de graft_spring = _Translations$suggestions$fruit_tree$graft_spring$de._(_root);
	@override late final _Translations$suggestions$fruit_tree$graft_budding$de graft_budding = _Translations$suggestions$fruit_tree$graft_budding$de._(_root);
}

// Path: suggestions.berries
class _Translations$suggestions$berries$de extends Translations$suggestions$berries$en {
	_Translations$suggestions$berries$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$berries$prune_winter$de prune_winter = _Translations$suggestions$berries$prune_winter$de._(_root);
	@override late final _Translations$suggestions$berries$fertilize_spring$de fertilize_spring = _Translations$suggestions$berries$fertilize_spring$de._(_root);
	@override late final _Translations$suggestions$berries$mulch$de mulch = _Translations$suggestions$berries$mulch$de._(_root);
	@override late final _Translations$suggestions$berries$treat_dormant$de treat_dormant = _Translations$suggestions$berries$treat_dormant$de._(_root);
}

// Path: suggestions.vegetable
class _Translations$suggestions$vegetable$de extends Translations$suggestions$vegetable$en {
	_Translations$suggestions$vegetable$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$vegetable$start_seedlings$de start_seedlings = _Translations$suggestions$vegetable$start_seedlings$de._(_root);
	@override late final _Translations$suggestions$vegetable$prick_out$de prick_out = _Translations$suggestions$vegetable$prick_out$de._(_root);
	@override late final _Translations$suggestions$vegetable$harden_off$de harden_off = _Translations$suggestions$vegetable$harden_off$de._(_root);
	@override late final _Translations$suggestions$vegetable$plant_out$de plant_out = _Translations$suggestions$vegetable$plant_out$de._(_root);
	@override late final _Translations$suggestions$vegetable$transplant$de transplant = _Translations$suggestions$vegetable$transplant$de._(_root);
	@override late final _Translations$suggestions$vegetable$sow_direct$de sow_direct = _Translations$suggestions$vegetable$sow_direct$de._(_root);
	@override late final _Translations$suggestions$vegetable$fertilize_season$de fertilize_season = _Translations$suggestions$vegetable$fertilize_season$de._(_root);
	@override late final _Translations$suggestions$vegetable$treat_window$de treat_window = _Translations$suggestions$vegetable$treat_window$de._(_root);
}

// Path: suggestions.herbs
class _Translations$suggestions$herbs$de extends Translations$suggestions$herbs$en {
	_Translations$suggestions$herbs$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$herbs$start_seedlings$de start_seedlings = _Translations$suggestions$herbs$start_seedlings$de._(_root);
	@override late final _Translations$suggestions$herbs$sow_direct$de sow_direct = _Translations$suggestions$herbs$sow_direct$de._(_root);
	@override late final _Translations$suggestions$herbs$plant_out$de plant_out = _Translations$suggestions$herbs$plant_out$de._(_root);
}

// Path: suggestions.tomato
class _Translations$suggestions$tomato$de extends Translations$suggestions$tomato$en {
	_Translations$suggestions$tomato$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$tomato$start_seedlings$de start_seedlings = _Translations$suggestions$tomato$start_seedlings$de._(_root);
	@override late final _Translations$suggestions$tomato$prick_out$de prick_out = _Translations$suggestions$tomato$prick_out$de._(_root);
	@override late final _Translations$suggestions$tomato$harden_off$de harden_off = _Translations$suggestions$tomato$harden_off$de._(_root);
	@override late final _Translations$suggestions$tomato$transplant$de transplant = _Translations$suggestions$tomato$transplant$de._(_root);
	@override late final _Translations$suggestions$tomato$stake$de stake = _Translations$suggestions$tomato$stake$de._(_root);
}

// Path: suggestions.shrub
class _Translations$suggestions$shrub$de extends Translations$suggestions$shrub$en {
	_Translations$suggestions$shrub$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$shrub$prune_spring$de prune_spring = _Translations$suggestions$shrub$prune_spring$de._(_root);
	@override late final _Translations$suggestions$shrub$overwinter$de overwinter = _Translations$suggestions$shrub$overwinter$de._(_root);
}

// Path: suggestions.hedge
class _Translations$suggestions$hedge$de extends Translations$suggestions$hedge$en {
	_Translations$suggestions$hedge$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$hedge$prune_early_summer$de prune_early_summer = _Translations$suggestions$hedge$prune_early_summer$de._(_root);
	@override late final _Translations$suggestions$hedge$prune_late_summer$de prune_late_summer = _Translations$suggestions$hedge$prune_late_summer$de._(_root);
}

// Path: suggestions.conifer
class _Translations$suggestions$conifer$de extends Translations$suggestions$conifer$en {
	_Translations$suggestions$conifer$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$conifer$prune$de prune = _Translations$suggestions$conifer$prune$de._(_root);
}

// Path: suggestions.houseplant
class _Translations$suggestions$houseplant$de extends Translations$suggestions$houseplant$en {
	_Translations$suggestions$houseplant$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$houseplant$repot$de repot = _Translations$suggestions$houseplant$repot$de._(_root);
	@override late final _Translations$suggestions$houseplant$fertilize_season$de fertilize_season = _Translations$suggestions$houseplant$fertilize_season$de._(_root);
	@override late final _Translations$suggestions$houseplant$overwinter$de overwinter = _Translations$suggestions$houseplant$overwinter$de._(_root);
}

// Path: suggestions.blueberry
class _Translations$suggestions$blueberry$de extends Translations$suggestions$blueberry$en {
	_Translations$suggestions$blueberry$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$blueberry$prune$de prune = _Translations$suggestions$blueberry$prune$de._(_root);
}

// Path: suggestions.cherry_laurel
class _Translations$suggestions$cherry_laurel$de extends Translations$suggestions$cherry_laurel$en {
	_Translations$suggestions$cherry_laurel$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cherry_laurel$prune_late_spring$de prune_late_spring = _Translations$suggestions$cherry_laurel$prune_late_spring$de._(_root);
	@override late final _Translations$suggestions$cherry_laurel$prune_late_summer$de prune_late_summer = _Translations$suggestions$cherry_laurel$prune_late_summer$de._(_root);
}

// Path: suggestions.hydrangea
class _Translations$suggestions$hydrangea$de extends Translations$suggestions$hydrangea$en {
	_Translations$suggestions$hydrangea$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$hydrangea$prune_old_wood$de prune_old_wood = _Translations$suggestions$hydrangea$prune_old_wood$de._(_root);
	@override late final _Translations$suggestions$hydrangea$prune_new_wood$de prune_new_wood = _Translations$suggestions$hydrangea$prune_new_wood$de._(_root);
}

// Path: suggestions.peach
class _Translations$suggestions$peach$de extends Translations$suggestions$peach$en {
	_Translations$suggestions$peach$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$peach$prune_spring$de prune_spring = _Translations$suggestions$peach$prune_spring$de._(_root);
}

// Path: suggestions.raspberry
class _Translations$suggestions$raspberry$de extends Translations$suggestions$raspberry$en {
	_Translations$suggestions$raspberry$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$raspberry$prune_late_winter$de prune_late_winter = _Translations$suggestions$raspberry$prune_late_winter$de._(_root);
	@override late final _Translations$suggestions$raspberry$prune_after_harvest$de prune_after_harvest = _Translations$suggestions$raspberry$prune_after_harvest$de._(_root);
}

// Path: suggestions.rose
class _Translations$suggestions$rose$de extends Translations$suggestions$rose$en {
	_Translations$suggestions$rose$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$rose$prune_spring$de prune_spring = _Translations$suggestions$rose$prune_spring$de._(_root);
	@override late final _Translations$suggestions$rose$overwinter$de overwinter = _Translations$suggestions$rose$overwinter$de._(_root);
}

// Path: suggestions.cucumber
class _Translations$suggestions$cucumber$de extends Translations$suggestions$cucumber$en {
	_Translations$suggestions$cucumber$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$cucumber$sow_direct$de sow_direct = _Translations$suggestions$cucumber$sow_direct$de._(_root);
}

// Path: suggestions.zucchini
class _Translations$suggestions$zucchini$de extends Translations$suggestions$zucchini$en {
	_Translations$suggestions$zucchini$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _Translations$suggestions$zucchini$sow_direct$de sow_direct = _Translations$suggestions$zucchini$sow_direct$de._(_root);
}

// Path: suggestions.cadence.overdue
class _Translations$suggestions$cadence$overdue$de extends Translations$suggestions$cadence$overdue$en {
	_Translations$suggestions$cadence$overdue$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} ist fällig';
	@override String get body => '{subject}: ca. {days_overdue} Tage über dem üblichen Rhythmus (~{cadence_days} Tage).';
}

// Path: suggestions.history.anniversary
class _Translations$suggestions$history$anniversary$de extends Translations$suggestions$history$anniversary$en {
	_Translations$suggestions$history$anniversary$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} — vor einem Jahr';
	@override String get body => 'Letztes Jahr um den {last_year_date} — {task} bei {subject}. Wieder fällig?';
}

// Path: suggestions.weather.window_open
class _Translations$suggestions$weather$window_open$de extends Translations$suggestions$weather$window_open$en {
	_Translations$suggestions$weather$window_open$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => '{task}: gutes Zeitfenster';
	@override String get body => 'Für {subject} steht eine trockene Phase an — ein guter Zeitpunkt.';
}

// Path: suggestions.community.most_started
class _Translations$suggestions$community$most_started$de extends Translations$suggestions$community$most_started$en {
	_Translations$suggestions$community$most_started$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => '{task} in der Nähe';
	@override String get body => 'Etwa {percent} % der Gärtner in deiner Nähe haben das diese Saison schon begonnen.';
}

// Path: suggestions.lawn.mow_due
class _Translations$suggestions$lawn$mow_due$de extends Translations$suggestions$lawn$mow_due$en {
	_Translations$suggestions$lawn$mow_due$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mähen fällig';
	@override String get body => '{subject} ist bereit zum Mähen.';
}

// Path: suggestions.lawn.water_drought
class _Translations$suggestions$lawn$water_drought$de extends Translations$suggestions$lawn$water_drought$en {
	_Translations$suggestions$lawn$water_drought$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gießen bei Trockenheit';
	@override String get body => '{subject} braucht bei trockenem Wetter eventuell Wasser.';
}

// Path: suggestions.lawn.fertilize_spring
class _Translations$suggestions$lawn$fertilize_spring$de extends Translations$suggestions$lawn$fertilize_spring$en {
	_Translations$suggestions$lawn$fertilize_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsdüngung';
	@override String get body => 'Dünge {subject} für die Saison — am besten bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.fertilize_autumn
class _Translations$suggestions$lawn$fertilize_autumn$de extends Translations$suggestions$lawn$fertilize_autumn$en {
	_Translations$suggestions$lawn$fertilize_autumn$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Herbstdüngung';
	@override String get body => 'Gib {subject} vor dem Winter eine Herbstdüngung — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.lawn.lime
class _Translations$suggestions$lawn$lime$de extends Translations$suggestions$lawn$lime$en {
	_Translations$suggestions$lawn$lime$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rasen kalken';
	@override String get body => 'Kalke {subject} bei saurem Boden — bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.moss_control
class _Translations$suggestions$lawn$moss_control$de extends Translations$suggestions$lawn$moss_control$en {
	_Translations$suggestions$lawn$moss_control$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Moosbekämpfung';
	@override String get body => 'Bekämpfe Moos in {subject} — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.lawn.weed_control
class _Translations$suggestions$lawn$weed_control$de extends Translations$suggestions$lawn$weed_control$en {
	_Translations$suggestions$lawn$weed_control$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unkrautbekämpfung';
	@override String get body => 'Geh das Unkraut in {subject} an — am besten bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.overseed_spring
class _Translations$suggestions$lawn$overseed_spring$de extends Translations$suggestions$lawn$overseed_spring$en {
	_Translations$suggestions$lawn$overseed_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nachsaat (Frühjahr)';
	@override String get body => 'Säe kahle Stellen in {subject} nach — bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.overseed_autumn
class _Translations$suggestions$lawn$overseed_autumn$de extends Translations$suggestions$lawn$overseed_autumn$en {
	_Translations$suggestions$lawn$overseed_autumn$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nachsaat (Herbst)';
	@override String get body => 'Übersäe {subject} im Herbst — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.lawn.scarify_spring
class _Translations$suggestions$lawn$scarify_spring$de extends Translations$suggestions$lawn$scarify_spring$en {
	_Translations$suggestions$lawn$scarify_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vertikutieren (Frühjahr)';
	@override String get body => 'Vertikutiere {subject} gegen Rasenfilz — bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.scarify_autumn
class _Translations$suggestions$lawn$scarify_autumn$de extends Translations$suggestions$lawn$scarify_autumn$en {
	_Translations$suggestions$lawn$scarify_autumn$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vertikutieren (Herbst)';
	@override String get body => 'Vertikutiere {subject} im Herbst — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.lawn.aerate
class _Translations$suggestions$lawn$aerate$de extends Translations$suggestions$lawn$aerate$en {
	_Translations$suggestions$lawn$aerate$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aerifizieren';
	@override String get body => 'Lüfte {subject} gegen Verdichtung — bis etwa {window_end_date}.';
}

// Path: suggestions.lawn.roll
class _Translations$suggestions$lawn$roll$de extends Translations$suggestions$lawn$roll$en {
	_Translations$suggestions$lawn$roll$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rasen walzen';
	@override String get body => 'Walze {subject} nach dem Winter — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.lawn.topdress
class _Translations$suggestions$lawn$topdress$de extends Translations$suggestions$lawn$topdress$en {
	_Translations$suggestions$lawn$topdress$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Topdressing';
	@override String get body => 'Sande {subject} ab und ebne ein — bis etwa {window_end_date}.';
}

// Path: suggestions.fruit_tree.fertilize_spring
class _Translations$suggestions$fruit_tree$fertilize_spring$de extends Translations$suggestions$fruit_tree$fertilize_spring$en {
	_Translations$suggestions$fruit_tree$fertilize_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsdüngung';
	@override String get body => 'Dünge deinen {subject} zu Wachstumsbeginn — bis etwa {window_end_date}.';
}

// Path: suggestions.fruit_tree.prune_winter
class _Translations$suggestions$fruit_tree$prune_winter$de extends Translations$suggestions$fruit_tree$prune_winter$en {
	_Translations$suggestions$fruit_tree$prune_winter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterschnitt';
	@override String get body => 'Schneide {subject} in der Ruhephase — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.treat_dormant
class _Translations$suggestions$fruit_tree$treat_dormant$de extends Translations$suggestions$fruit_tree$treat_dormant$en {
	_Translations$suggestions$fruit_tree$treat_dormant$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterspritzung';
	@override String get body => 'Behandle {subject} mit einer Winterspritzung — bis etwa {window_end_date}.';
}

// Path: suggestions.fruit_tree.mulch
class _Translations$suggestions$fruit_tree$mulch$de extends Translations$suggestions$fruit_tree$mulch$en {
	_Translations$suggestions$fruit_tree$mulch$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mulchen';
	@override String get body => 'Mulche um {subject}, um Feuchtigkeit zu halten — bis etwa {window_end_date}.';
}

// Path: suggestions.fruit_tree.thin_fruit
class _Translations$suggestions$fruit_tree$thin_fruit$de extends Translations$suggestions$fruit_tree$thin_fruit$en {
	_Translations$suggestions$fruit_tree$thin_fruit$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Früchte ausdünnen';
	@override String get body => 'Dünne die Fruchtansätze von {subject} aus — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_spring
class _Translations$suggestions$fruit_tree$graft_spring$de extends Translations$suggestions$fruit_tree$graft_spring$en {
	_Translations$suggestions$fruit_tree$graft_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsveredelung';
	@override String get body => 'Veredle {subject} beim Saftaufstieg — bis etwa {window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_budding
class _Translations$suggestions$fruit_tree$graft_budding$de extends Translations$suggestions$fruit_tree$graft_budding$en {
	_Translations$suggestions$fruit_tree$graft_budding$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sommerokulation';
	@override String get body => 'Okuliere {subject} im Spätsommer — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.berries.prune_winter
class _Translations$suggestions$berries$prune_winter$de extends Translations$suggestions$berries$prune_winter$en {
	_Translations$suggestions$berries$prune_winter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterschnitt';
	@override String get body => 'Schneide {subject} in der Ruhephase — bis etwa {window_end_date}.';
}

// Path: suggestions.berries.fertilize_spring
class _Translations$suggestions$berries$fertilize_spring$de extends Translations$suggestions$berries$fertilize_spring$en {
	_Translations$suggestions$berries$fertilize_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsdüngung';
	@override String get body => 'Dünge {subject} zu Wachstumsbeginn — bis etwa {window_end_date}.';
}

// Path: suggestions.berries.mulch
class _Translations$suggestions$berries$mulch$de extends Translations$suggestions$berries$mulch$en {
	_Translations$suggestions$berries$mulch$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mulchen';
	@override String get body => 'Mulche {subject} für kühle, feuchte Wurzeln — bis etwa {window_end_date}.';
}

// Path: suggestions.berries.treat_dormant
class _Translations$suggestions$berries$treat_dormant$de extends Translations$suggestions$berries$treat_dormant$en {
	_Translations$suggestions$berries$treat_dormant$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterspritzung';
	@override String get body => 'Behandle {subject} mit einer Winterspritzung — bis etwa {window_end_date}.';
}

// Path: suggestions.vegetable.start_seedlings
class _Translations$suggestions$vegetable$start_seedlings$de extends Translations$suggestions$vegetable$start_seedlings$en {
	_Translations$suggestions$vegetable$start_seedlings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Anzucht starten';
	@override String get body => 'Säe {subject} drinnen für das spätere Auspflanzen — bis etwa {window_end_date}.';
}

// Path: suggestions.vegetable.prick_out
class _Translations$suggestions$vegetable$prick_out$de extends Translations$suggestions$vegetable$prick_out$en {
	_Translations$suggestions$vegetable$prick_out$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pikieren';
	@override String get body => '{subject} wurde vor {days_since} Tagen ausgesät — pikiere die Sämlinge in Töpfe.';
}

// Path: suggestions.vegetable.harden_off
class _Translations$suggestions$vegetable$harden_off$de extends Translations$suggestions$vegetable$harden_off$en {
	_Translations$suggestions$vegetable$harden_off$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Abhärten';
	@override String get body => 'Gewöhne {subject} vor dem Auspflanzen draußen ab — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.vegetable.plant_out
class _Translations$suggestions$vegetable$plant_out$de extends Translations$suggestions$vegetable$plant_out$en {
	_Translations$suggestions$vegetable$plant_out$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Auspflanzen';
	@override String get body => 'Pflanze {subject} aus, sobald kein Frost mehr droht — um {frost_date}.';
}

// Path: suggestions.vegetable.transplant
class _Translations$suggestions$vegetable$transplant$de extends Translations$suggestions$vegetable$transplant$en {
	_Translations$suggestions$vegetable$transplant$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Umpflanzen';
	@override String get body => 'Setze {subject} nach dem Frost an den endgültigen Platz — um {frost_date}.';
}

// Path: suggestions.vegetable.sow_direct
class _Translations$suggestions$vegetable$sow_direct$de extends Translations$suggestions$vegetable$sow_direct$en {
	_Translations$suggestions$vegetable$sow_direct$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Direktsaat';
	@override String get body => 'Säe {subject} direkt ins Freie, sobald es mild wird — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.vegetable.fertilize_season
class _Translations$suggestions$vegetable$fertilize_season$de extends Translations$suggestions$vegetable$fertilize_season$en {
	_Translations$suggestions$vegetable$fertilize_season$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Düngen';
	@override String get body => 'Dünge {subject} während der Wachstumszeit.';
}

// Path: suggestions.vegetable.treat_window
class _Translations$suggestions$vegetable$treat_window$de extends Translations$suggestions$vegetable$treat_window$en {
	_Translations$suggestions$vegetable$treat_window$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kontrollieren';
	@override String get body => 'Prüfe {subject} und behandle bei Bedarf — am besten bei trockenem Wetter.';
}

// Path: suggestions.herbs.start_seedlings
class _Translations$suggestions$herbs$start_seedlings$de extends Translations$suggestions$herbs$start_seedlings$en {
	_Translations$suggestions$herbs$start_seedlings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Anzucht starten';
	@override String get body => 'Säe {subject} drinnen für einen Vorsprung — bis etwa {window_end_date}.';
}

// Path: suggestions.herbs.sow_direct
class _Translations$suggestions$herbs$sow_direct$de extends Translations$suggestions$herbs$sow_direct$en {
	_Translations$suggestions$herbs$sow_direct$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Direktsaat';
	@override String get body => 'Säe {subject} direkt ins Freie, sobald es mild wird — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.herbs.plant_out
class _Translations$suggestions$herbs$plant_out$de extends Translations$suggestions$herbs$plant_out$en {
	_Translations$suggestions$herbs$plant_out$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Auspflanzen';
	@override String get body => 'Pflanze {subject} aus, sobald kein Frost mehr droht — um {frost_date}.';
}

// Path: suggestions.tomato.start_seedlings
class _Translations$suggestions$tomato$start_seedlings$de extends Translations$suggestions$tomato$start_seedlings$en {
	_Translations$suggestions$tomato$start_seedlings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Anzucht starten';
	@override String get body => 'Säe {subject} drinnen für einen Vorsprung — bis etwa {window_end_date}.';
}

// Path: suggestions.tomato.prick_out
class _Translations$suggestions$tomato$prick_out$de extends Translations$suggestions$tomato$prick_out$en {
	_Translations$suggestions$tomato$prick_out$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pikieren';
	@override String get body => '{subject} wurde vor {days_since} Tagen ausgesät — pikiere die Sämlinge in Töpfe.';
}

// Path: suggestions.tomato.harden_off
class _Translations$suggestions$tomato$harden_off$de extends Translations$suggestions$tomato$harden_off$en {
	_Translations$suggestions$tomato$harden_off$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Abhärten';
	@override String get body => 'Gewöhne {subject} vor dem Auspflanzen draußen ab — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.tomato.transplant
class _Translations$suggestions$tomato$transplant$de extends Translations$suggestions$tomato$transplant$en {
	_Translations$suggestions$tomato$transplant$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Umpflanzen';
	@override String get body => '{subject} wächst seit {days_since} Tagen — an den endgültigen Platz setzen.';
}

// Path: suggestions.tomato.stake
class _Translations$suggestions$tomato$stake$de extends Translations$suggestions$tomato$stake$en {
	_Translations$suggestions$tomato$stake$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stützen';
	@override String get body => '{subject}: {days_since} Tage Wachstum — Stab oder Stütze anbringen.';
}

// Path: suggestions.shrub.prune_spring
class _Translations$suggestions$shrub$prune_spring$de extends Translations$suggestions$shrub$prune_spring$en {
	_Translations$suggestions$shrub$prune_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsschnitt';
	@override String get body => 'Schneide {subject} nach Bedarf — bis etwa {window_end_date}.';
}

// Path: suggestions.shrub.overwinter
class _Translations$suggestions$shrub$overwinter$de extends Translations$suggestions$shrub$overwinter$en {
	_Translations$suggestions$shrub$overwinter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterschutz';
	@override String get body => 'Schütze {subject} vor dem ersten starken Frost — bis etwa {window_end_date}.';
}

// Path: suggestions.hedge.prune_early_summer
class _Translations$suggestions$hedge$prune_early_summer$de extends Translations$suggestions$hedge$prune_early_summer$en {
	_Translations$suggestions$hedge$prune_early_summer$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühsommerschnitt';
	@override String get body => 'Schneide {subject} in Form — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.hedge.prune_late_summer
class _Translations$suggestions$hedge$prune_late_summer$de extends Translations$suggestions$hedge$prune_late_summer$en {
	_Translations$suggestions$hedge$prune_late_summer$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spätsommerschnitt';
	@override String get body => 'Gib {subject} vor dem Herbst einen letzten Schnitt — bis etwa {window_end_date}.';
}

// Path: suggestions.conifer.prune
class _Translations$suggestions$conifer$prune$de extends Translations$suggestions$conifer$prune$en {
	_Translations$suggestions$conifer$prune$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rückschnitt';
	@override String get body => 'Schneide {subject} leicht ins neue Wachstum — bis etwa {window_end_date}.';
}

// Path: suggestions.houseplant.repot
class _Translations$suggestions$houseplant$repot$de extends Translations$suggestions$houseplant$repot$en {
	_Translations$suggestions$houseplant$repot$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Umtopfen';
	@override String get body => 'Topfe {subject} bei Wachstumsbeginn um — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.houseplant.fertilize_season
class _Translations$suggestions$houseplant$fertilize_season$de extends Translations$suggestions$houseplant$fertilize_season$en {
	_Translations$suggestions$houseplant$fertilize_season$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Düngen';
	@override String get body => 'Dünge {subject} während der aktiven Wachstumszeit.';
}

// Path: suggestions.houseplant.overwinter
class _Translations$suggestions$houseplant$overwinter$de extends Translations$suggestions$houseplant$overwinter$en {
	_Translations$suggestions$houseplant$overwinter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Reinholen';
	@override String get body => 'Hole {subject} vor dem ersten Frost ins Haus — bis etwa {window_end_date}.';
}

// Path: suggestions.blueberry.prune
class _Translations$suggestions$blueberry$prune$de extends Translations$suggestions$blueberry$prune$en {
	_Translations$suggestions$blueberry$prune$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schnitt';
	@override String get body => 'Schneide {subject} in der Ruhephase — bis etwa {window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_spring
class _Translations$suggestions$cherry_laurel$prune_late_spring$de extends Translations$suggestions$cherry_laurel$prune_late_spring$en {
	_Translations$suggestions$cherry_laurel$prune_late_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spätfrühlingsschnitt';
	@override String get body => 'Schneide {subject} nach dem ersten Austrieb — Zeitfenster bis ~{window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_summer
class _Translations$suggestions$cherry_laurel$prune_late_summer$de extends Translations$suggestions$cherry_laurel$prune_late_summer$en {
	_Translations$suggestions$cherry_laurel$prune_late_summer$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spätsommerschnitt';
	@override String get body => 'Schneide {subject} ein zweites Mal — bis etwa {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_old_wood
class _Translations$suggestions$hydrangea$prune_old_wood$de extends Translations$suggestions$hydrangea$prune_old_wood$en {
	_Translations$suggestions$hydrangea$prune_old_wood$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schnitt (altes Holz)';
	@override String get body => 'Verblühtes ausputzen und {subject} am alten Holz nach der Blüte schneiden — bis etwa {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_new_wood
class _Translations$suggestions$hydrangea$prune_new_wood$de extends Translations$suggestions$hydrangea$prune_new_wood$en {
	_Translations$suggestions$hydrangea$prune_new_wood$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schnitt (neues Holz)';
	@override String get body => 'Schneide {subject} am neuen Holz im Spätwinter zurück — bis etwa {window_end_date}.';
}

// Path: suggestions.peach.prune_spring
class _Translations$suggestions$peach$prune_spring$de extends Translations$suggestions$peach$prune_spring$en {
	_Translations$suggestions$peach$prune_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsschnitt';
	@override String get body => 'Schneide {subject} beim Knospenschwellen gegen Kräuselkrankheit — bis etwa {window_end_date}.';
}

// Path: suggestions.raspberry.prune_late_winter
class _Translations$suggestions$raspberry$prune_late_winter$de extends Translations$suggestions$raspberry$prune_late_winter$en {
	_Translations$suggestions$raspberry$prune_late_winter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Spätwinterschnitt';
	@override String get body => 'Schneide die Ruten von {subject} vor dem Austrieb — bis etwa {window_end_date}.';
}

// Path: suggestions.raspberry.prune_after_harvest
class _Translations$suggestions$raspberry$prune_after_harvest$de extends Translations$suggestions$raspberry$prune_after_harvest$en {
	_Translations$suggestions$raspberry$prune_after_harvest$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schnitt nach der Ernte';
	@override String get body => '{subject} hat vor {days_since} Tagen getragen — schneide die alten Ruten heraus.';
}

// Path: suggestions.rose.prune_spring
class _Translations$suggestions$rose$prune_spring$de extends Translations$suggestions$rose$prune_spring$en {
	_Translations$suggestions$rose$prune_spring$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Frühjahrsschnitt';
	@override String get body => 'Schneide {subject} beim Austrieb — bis etwa {window_end_date}.';
}

// Path: suggestions.rose.overwinter
class _Translations$suggestions$rose$overwinter$de extends Translations$suggestions$rose$overwinter$en {
	_Translations$suggestions$rose$overwinter$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Winterschutz';
	@override String get body => 'Häufle {subject} an oder schütze sie vor starkem Frost — bis etwa {window_end_date}.';
}

// Path: suggestions.cucumber.sow_direct
class _Translations$suggestions$cucumber$sow_direct$de extends Translations$suggestions$cucumber$sow_direct$en {
	_Translations$suggestions$cucumber$sow_direct$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Direktsaat';
	@override String get body => 'Säe {subject} ins Freie, sobald es warm und frostfrei ist — um {frost_date}.';
}

// Path: suggestions.zucchini.sow_direct
class _Translations$suggestions$zucchini$sow_direct$de extends Translations$suggestions$zucchini$sow_direct$en {
	_Translations$suggestions$zucchini$sow_direct$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Direktsaat';
	@override String get body => 'Säe {subject} nach dem Frost ins Freie — um {frost_date}.';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsDe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.tagline' => 'Dein Gartentagebuch 🌿',
			'nav.home' => 'Startseite',
			'nav.journal' => 'Tagebuch',
			'nav.areas' => 'Garten',
			'nav.tasks' => 'Aufgaben',
			'home.greeting' => 'Guten Tag 🌿',
			'home.today' => 'Heute',
			'home.recent' => 'Zuletzt',
			'home.no_tasks_today' => 'Heute keine geplanten Aufgaben.',
			'home.no_recent' => 'Noch keine erledigten Aufgaben.',
			'home.overdue_banner' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '1 überfällige Aufgabe', other: '${n} überfällige Aufgaben', ), 
			'common.today' => 'Heute',
			'common.yesterday' => 'gestern',
			'common.load_error' => 'Daten konnten nicht geladen werden.',
			'swipe.complete' => 'Erledigt',
			'swipe.postpone' => '+1 Tag',
			'swipe.revert' => 'Zurück',
			'swipe.edit' => 'Bearbeiten',
			'swipe.move' => 'Verschieben',
			'swipe.delete' => 'Löschen',
			'notifications.today' => 'Heute',
			'notifications.tomorrow' => 'Morgen',
			'notif_priming.title' => 'Soll ich dich rechtzeitig erinnern?',
			'notif_priming.why' => 'Damit dir keine Aufgabe entgeht — die Erinnerung kommt genau dann, wenn du sie eingestellt hast.',
			'notif_priming.benefit_reminders' => 'Aufgaben-Erinnerungen — z. B. „1 Tag vorher um 18:00“.',
			'notif_priming.benefit_weather' => 'Smarter Wetter-Hinweis — „morgen trocken, guter Zeitpunkt“. (optional)',
			'notif_priming.benefit_nearby' => 'Hinweise aus der Umgebung — was andere in deiner Nähe tun. (V2, optional)',
			'notif_priming.privacy' => 'Du kannst jede Art einzeln ein- oder ausschalten, Ruhezeiten festlegen und die Häufigkeit begrenzen. Kein Spam.',
			'notif_priming.enable' => 'Benachrichtigungen aktivieren',
			'notif_priming.later' => 'Vielleicht später',
			'notif_settings.title' => 'Benachrichtigungen',
			'notif_settings.load_error' => 'Einstellungen konnten nicht geladen werden.',
			'notif_settings.section_types' => 'Benachrichtigungsarten',
			'notif_settings.type_reminders' => 'Aufgaben-Erinnerungen',
			'notif_settings.type_reminders_sub' => 'lokal · funktionieren ohne Internet',
			'notif_settings.type_weather' => 'Smarte Hinweise (Wetter)',
			'notif_settings.type_weather_sub' => '„morgen trocken — ein guter Zeitpunkt“',
			'notif_settings.type_community' => 'Hinweise aus der Umgebung',
			'notif_settings.type_community_sub' => 'was andere in der Nähe tun',
			'notif_settings.section_default_offset' => 'Standard-Vorlaufzeit',
			'notif_settings.default_offset_hint' => 'Füllt neue Aufgaben vor; jederzeit änderbar.',
			'notif_settings.section_quiet' => 'Damit du nicht überflutet wirst',
			'notif_settings.quiet_hours' => 'Ruhezeiten',
			'notif_settings.quiet_hours_sub' => ({required Object range}) => '${range}, keine Benachrichtigungen',
			'notif_settings.frequency_cap' => 'Höchstens 1 Hinweis pro Tag',
			'notif_settings.frequency_cap_sub' => 'Wetter und Umgebung in einer Zusammenfassung',
			'notif_settings.section_more' => 'Mehr',
			'notif_settings.preview' => 'Benachrichtigungs-Vorschau',
			'notif_settings.preview_sub' => 'wie sie auf dem Sperrbildschirm aussehen',
			'notif_settings.system_permission' => 'Systemberechtigung',
			'notif_settings.system_permission_on' => 'Gerät: erlaubt',
			'notif_settings.system_permission_off' => 'exakte Erinnerungen nicht erlaubt — für Einstellungen tippen',
			'notif_settings.hints_perm_denied' => 'Benachrichtigungen sind deaktiviert, daher können Hinweise nicht aktiviert werden.',
			'notif_preview.title' => 'Benachrichtigungen — Vorschau',
			'notif_preview.date' => 'Dienstag, 1. Juni',
			'notif_preview.rem_now' => 'jetzt',
			'notif_preview.rem_title' => '⏰ Blattspritzung · 07:00',
			'notif_preview.rem_body' => 'Hecke + Rasen · der Morgen ist trocken — guter Zeitpunkt.',
			'notif_preview.rem_tag' => 'Aufgaben-Erinnerung',
			'notif_preview.wx_title' => 'Morgen früh wird es trocken ☀️',
			'notif_preview.wx_body' => 'Guter Zeitpunkt für die Blattspritzung von Kirschlorbeer.',
			'notif_preview.wx_tag' => 'Smarter Hinweis · Wetter',
			'notif_preview.com_yesterday' => 'gestern',
			'notif_preview.com_title' => 'Deine Umgebung',
			'notif_preview.com_body' => '68 % der Gärtner in deiner Nähe haben diese Woche zum ersten Mal den Rasen gedüngt.',
			'notif_preview.com_tag' => 'Hinweis aus der Umgebung · V2',
			'notif_preview.footer' => 'Ein Tippen auf eine Benachrichtigung öffnet den passenden Bildschirm (Aufgabe · Hinweis · Umgebung).',
			'onboarding.skip' => 'Überspringen ›',
			'onboarding.next' => 'Weiter',
			'onboarding.start' => 'Loslegen 🌿',
			'onboarding.soon_badge' => 'bald (V2)',
			'onboarding.welcome_title' => 'Willkommen bei Tendask',
			'onboarding.welcome_body' => 'Dein einfaches Tagebuch für Garten, Rasen und Hecke — jede Aufgabe an einem Ort.',
			'onboarding.log_title' => 'In Sekunden festhalten',
			'onboarding.log_body' => 'Gemäht, gegossen, gedüngt? Notiere was, wann und wo — mit wenigen Fingertipps. Das Wetter wird automatisch gespeichert.',
			'onboarding.remind_title' => 'Erinnerungen + Wetter',
			'onboarding.remind_body' => 'Plane Aufgaben, erhalte eine Erinnerung auf dein Handy und einen Wetterhinweis — „morgen früh trocken, gute Zeit zum Spritzen“.',
			'onboarding.nearby_title' => 'Deine Umgebung',
			'onboarding.nearby_body' => 'Später: sieh, was Gärtner mit ähnlichem Klima in deiner Nähe tun — anonym und privat.',
			'auth.title' => 'Willkommen bei Tendask',
			'auth.value_prop' => 'Sichere dein Gartentagebuch und verliere deine Historie nicht beim Handywechsel.',
			'auth.continue_apple' => 'Mit Apple fortfahren',
			'auth.continue_google' => 'Mit Google fortfahren',
			'auth.continue_email' => 'Mit E-Mail fortfahren',
			'auth.guest' => 'Ohne Konto ausprobieren',
			'auth.legal' => 'Wir senden einen Bestätigungscode per E-Mail (ohne Passwort). Mit dem Fortfahren stimmst du den Bedingungen und dem Datenschutz zu.',
			'auth.guest_warning' => 'Ohne Konto gehen alle Daten verloren, wenn du die App entfernst oder das Gerät wechselst.',
			'auth.google_error' => 'Google-Anmeldung fehlgeschlagen. Bitte versuche es erneut.',
			'auth.coming_soon' => 'Demnächst verfügbar.',
			'auth.privacy_link' => 'Datenschutzerklärung',
			'email_login.title' => 'Mit E-Mail anmelden',
			'email_login.email_label' => 'E-Mail-Adresse',
			'email_login.email_hint' => 'du@beispiel.de',
			'email_login.send_code' => 'Code senden',
			'email_login.intro' => 'Wir senden dir einen Einmalcode — ohne Passwort.',
			'email_login.code_label' => 'Code aus der E-Mail',
			'email_login.code_hint' => 'Erhaltenen Code eingeben',
			'email_login.code_sent' => ({required Object email}) => 'Wir haben einen Code an ${email} gesendet. Gib ihn unten ein.',
			'email_login.verify' => 'Bestätigen und anmelden',
			'email_login.resend' => 'Neuen Code senden',
			'email_login.err_email' => 'Gib eine gültige E-Mail-Adresse ein.',
			'email_login.err_code' => 'Gib den Code aus der E-Mail ein.',
			'email_login.err_send' => 'Code konnte nicht gesendet werden. Prüfe deine Verbindung und versuche es erneut.',
			'email_login.err_verify' => 'Der Code ist falsch oder abgelaufen. Versuche es erneut.',
			'email_login.err_email_domain' => 'Die Domain dieser E-Mail wurde nicht gefunden. Prüfe die Adresse.',
			'email_login.did_you_mean' => ({required Object suggestion}) => 'Meintest du ${suggestion}?',
			'email_login.resend_in' => ({required Object seconds}) => 'Neuen Code senden (${seconds} s)',
			'location.title' => 'Wo gärtnerst du?',
			'location.why' => 'Wir brauchen deinen Standort für die lokale Wettervorhersage und (später), um dir zu zeigen, was Gärtner in einem ähnlichen Klima tun.',
			'location.use_gps' => 'Meinen Standort verwenden',
			'location.enter_place' => 'Ort eingeben',
			'location.or' => 'oder',
			'location.gps_sub' => 'Automatisch per Geräte-GPS',
			'location.place_hint' => 'Dorf, Stadt oder Adresse (z. B. Šentjur)',
			'location.place_note' => 'Ein Dorf oder eine Stadt genügt — keine genaue Adresse nötig.',
			'location.search' => 'Suchen',
			'location.privacy' => 'Wir speichern deinen genauen Standort nie. Wir behalten nur eine ungefähre Umgebung (ein größeres Gebiet von wenigen Kilometern), die wir niemals an andere weitergeben.',
			'location.kContinue' => 'Weiter',
			'location.set_gps' => 'Standort festgelegt.',
			'location.set_place' => ({required Object name}) => 'Standort: ${name}',
			'location.err_denied' => 'Standortzugriff verweigert. Gib einen Ort ein oder erlaube den Zugriff in den Systemeinstellungen.',
			'location.err_disabled' => 'Standortdienste sind aus. Schalte sie ein oder gib einen Ort ein.',
			'location.err_unavailable' => 'Standort konnte nicht ermittelt werden. Versuche es erneut oder gib einen Ort ein.',
			'location.err_search' => 'Suche fehlgeschlagen. Prüfe deine Verbindung und versuche es erneut.',
			'location.no_results' => 'Keine Treffer für diesen Ort.',
			'location.screen_title' => 'Gartenstandort',
			'location.status_set' => 'Standort ist festgelegt',
			'location.status_set_at' => ({required Object name}) => 'Standort ist festgelegt · ${name}',
			'location.status_unset' => 'Standort noch nicht festgelegt',
			'location.clear' => 'Standort entfernen',
			'location.clear_confirm_title' => 'Standort entfernen?',
			'location.clear_confirm_body' => 'Das Wetter verwendet die Standardregion, bis du einen neuen Standort festlegst.',
			'location.clear_confirm_yes' => 'Entfernen',
			'location.clear_confirm_cancel' => 'Abbrechen',
			'location.cleared' => 'Standort entfernt',
			'journal.title' => 'Tagebuch',
			'journal.subtitle' => 'Gartentagebuch',
			'journal.filter_all' => 'Alle',
			'journal.filter_tasks' => '✓ Aufgaben',
			'journal.filter_notes' => '✍️ Notizen',
			'journal.empty' => 'Noch keine Einträge.',
			'journal.empty_tasks' => 'Keine erledigten Aufgaben.',
			'journal.empty_notes' => 'Noch keine Notizen.',
			'journal.timeline' => 'Zeitleiste',
			'journal.month_view' => 'Monat',
			'journal.month_hint' => '💡 Tippe auf einen Tag, um Aufgaben zu sehen und hinzuzufügen.',
			'journal.month_count' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} Aufgabe diesen Monat', other: '${n} Aufgaben diesen Monat', ), 
			'journal.day_empty' => 'Keine Aufgaben an diesem Tag.',
			'journal.day_add' => 'Aufgabe an diesem Tag hinzufügen',
			'notes.title_new' => 'Neue Notiz',
			'notes.title_edit' => 'Notiz bearbeiten',
			'notes.content_label' => 'Notiz',
			'notes.content_hint' => 'Freier Text — Beobachtung, Idee, Gedanke…',
			'notes.when' => 'Wann',
			'notes.today' => 'Heute',
			'notes.yesterday' => 'Gestern',
			'notes.pick_date' => 'Datum…',
			'notes.area' => 'Bereich (optional)',
			'notes.no_areas' => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.',
			'notes.plant' => 'Pflanze (optional)',
			'notes.save' => 'Notiz speichern',
			'notes.err_content' => 'Notiztext eingeben.',
			'notes.delete' => 'Notiz löschen',
			'notes.delete_confirm' => 'Diese Aktion kann nicht rückgängig gemacht werden.',
			'notes.info' => '🌧️ Das Wetter wird automatisch gespeichert.',
			'task_detail.section_weather' => 'Wetteraufnahme',
			'task_detail.section_details' => 'Details',
			'task_detail.label_supplies' => 'Mittel',
			'task_detail.label_reminder' => 'Erinnerung',
			'task_detail.label_recurrence' => 'Wiederholung',
			'task_detail.label_note' => 'Notiz',
			'task_detail.badge_waiting' => 'Geplant',
			'task_detail.badge_done' => 'Erledigt',
			'task_detail.action_complete' => '✓  Als erledigt markieren',
			'task_detail.action_postpone' => '+1 Tag',
			'task_detail.action_edit' => 'Bearbeiten',
			'task_detail.action_duplicate' => 'Duplizieren',
			'task_detail.action_delete' => 'Löschen',
			'task_detail.action_revert' => 'Zurück auf Ausstehend',
			'task_detail.action_move' => 'Verschieben',
			'task_detail.recurrence_once' => 'Einmalig',
			'task_detail.recurrence_weekly' => 'Wöchentlich',
			'task_detail.recurrence_seasonal' => 'Saisonal',
			'task_detail.none' => '—',
			'task_detail.not_found' => 'Aufgabe nicht gefunden.',
			'tasks_list.title' => 'Aufgaben',
			'tasks_list.subtitle' => 'bevorstehende und überfällige',
			'tasks_list.section_overdue' => 'Überfällig',
			'tasks_list.section_today' => 'Heute',
			'tasks_list.section_tomorrow' => 'Morgen',
			'tasks_list.section_this_week' => 'Diese Woche',
			'tasks_list.section_later' => 'Später',
			'tasks_list.empty' => 'Keine offenen Aufgaben. Mit + hinzufügen.',
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '1 Tag überfällig', other: '${n} Tage überfällig', ), 
			'tasks_list.status_today' => 'heute',
			'tasks_list.status_tomorrow' => 'morgen',
			'tasks_list.action_complete' => 'Erledigt',
			'tasks_list.action_postpone' => '+1 Tag',
			'tasks_list.action_edit' => 'Bearbeiten',
			'tasks_list.action_duplicate' => 'Duplizieren',
			'tasks_list.action_delete' => 'Löschen',
			'tasks_list.delete_confirm_title' => 'Aufgabe löschen?',
			'tasks_list.delete_confirm_body' => 'Diese Aktion kann nicht rückgängig gemacht werden.',
			'tasks_list.delete_yes' => 'Löschen',
			'tasks_list.delete_cancel' => 'Abbrechen',
			'subject_picker.title' => 'Pflanze oder Bereich',
			'subject_picker.choose' => 'Wählen',
			'entry.title_new' => 'Neue Aufgabe',
			'entry.title_review' => 'Überprüfen',
			'entry.kContinue' => 'Weiter',
			'entry.skip' => 'Überspringen',
			'entry.save' => 'Aufgabe speichern',
			'entry.step' => 'Schritt',
			'entry.note_card_title' => 'Nur eine Notiz, keine Aufgabe?',
			'entry.note_card_action' => 'Notiz ›',
			'entry.repeat_last' => 'Letztes wiederholen',
			'entry.type_title' => 'Welche Aufgabe?',
			'entry.type_hint' => 'Ein Tipp auf eine Aufgabe bringt dich automatisch weiter.',
			'entry.type_show_all' => ({required Object n}) => 'Alle anzeigen (${n})',
			'entry.type_show_less' => 'Weniger anzeigen',
			'entry.subject_title' => 'Wofür?',
			'entry.subject_search_hint' => 'Pflanze suchen…',
			'entry.subject_plants' => 'Pflanzen',
			'entry.subject_add_plant' => 'Pflanze hinzufügen',
			'entry.subject_add_area' => 'Bereich hinzufügen',
			'entry.subject_from_catalog' => 'Aus Katalog hinzufügen',
			'entry.subject_areas_context' => 'Bereiche:',
			'entry.subject_area_section' => 'Oder der ganze Bereich',
			'entry.subject_area_note' => 'Wähle einen Bereich nur, wenn die Aufgabe für das Ganze ohne einzelne Pflanze gilt (Mähen, ein ganzes Beet mulchen).',
			'entry.when_title' => 'Wann',
			'entry.when_today' => 'Heute',
			'entry.when_tomorrow' => 'Morgen',
			'entry.when_pick_date' => 'Datum…',
			'entry.when_date' => 'Datum',
			'entry.when_time' => 'Uhrzeit',
			'entry.when_default_note' => 'Standard: heute zur nächsten vollen Stunde.',
			'entry.when_status' => 'Status',
			'entry.when_status_waiting' => 'Wartet',
			'entry.when_status_done' => 'Erledigt',
			'entry.when_status_note' => 'Standard aus Datum und Uhrzeit: Zukunft = wartet, sonst = erledigt.',
			'entry.reminder_title' => 'Erinnerung',
			'entry.optional' => '(optional)',
			'entry.reminder_why' => 'Dieser Schritt ist da, weil die Aufgabe geplant ist (Wartet). Eine Erinnerung benachrichtigt dich zur gewählten Zeit auf dem Handy.',
			'entry.reminder_add' => 'Erinnerung hinzufügen',
			'entry.reminder_note' => 'Einstellbarer Vorlauf und Uhrzeit. Mehrere Erinnerungen pro Aufgabe.',
			'entry.supplies_title' => 'Mittel',
			'entry.supplies_why' => 'Dieser Schritt ist da, weil die Aufgabe normalerweise Mittel verbraucht. Sie werden vom Bestand abgezogen.',
			'entry.supplies_add' => 'Mittel aus Bestand hinzufügen',
			'entry.supplies_note' => 'Eine Mischung für alle gewählten Pflanzen — einmal abgezogen.',
			'entry.review_title' => 'Überprüfen — tippe eine Zeile zum Bearbeiten',
			'entry.review_type' => 'Aufgabe',
			'entry.review_subject' => 'Wofür',
			'entry.review_when' => 'Wann',
			'entry.review_reminder' => 'Erinnerung',
			'entry.review_supplies' => 'Mittel',
			'entry.review_fix' => 'Bearbeiten',
			'entry.review_none' => '—',
			'entry.note_label' => 'Notiz',
			'entry.note_hint' => 'z. B. morgens vor angesagtem Regen',
			'entry.weather_note' => '🌧️ Das Wetter wird beim Abschluss automatisch gespeichert.',
			'entry.err_subject' => 'Wähle mindestens eine Pflanze oder einen Bereich.',
			'entry.rem_event' => 'Zum Zeitpunkt',
			'entry.rem_10min' => '10 Minuten vorher',
			'entry.rem_1hour' => '1 Stunde vorher',
			'entry.rem_1day' => '1 Tag vorher',
			'entry.rem_2day' => '2 Tage vorher',
			'entry.rem_custom' => 'Eigene…',
			'entry.rem_unit_min' => 'Min',
			'entry.rem_unit_hour' => 'Std',
			'entry.rem_unit_day' => 'Tage',
			'entry.rem_custom_label' => 'Wie lange vorher?',
			'entry.rem_before' => 'vorher',
			'entry.rem_at' => ({required Object t}) => 'um ${t}',
			'entry.rem_choose_time' => 'Um Uhrzeit',
			'entry.rem_time_note' => 'Die Uhrzeit gilt bei tagbasiertem Vorlauf (z. B. „1 Tag vorher um 18:00“).',
			'entry.rem_perm_denied' => 'Benachrichtigungen sind deaktiviert, daher kann keine Erinnerung hinzugefügt werden.',
			'entry.rem_exact_title' => 'Exakte Erinnerungen erlauben',
			'entry.rem_exact_body' => 'Damit sie zur exakten Zeit ausgelöst wird, benötigt Tendask die Berechtigung „Wecker und Erinnerungen“. Aktiviere sie in den Einstellungen und füge die Erinnerung erneut hinzu.',
			'entry.rem_exact_open' => 'Einstellungen öffnen',
			'entry.rem_added' => 'bereits hinzugefügt',
			'plant_edit.title_edit' => 'Pflanze bearbeiten',
			'plant_edit.species' => 'Art',
			'plant_edit.alias' => 'Eigener Name (optional)',
			'plant_edit.alias_hint' => 'z. B. „alter Apfel am Zaun“',
			'plant_edit.alias_note' => 'Nur du siehst ihn; wird statt des Standardnamens angezeigt.',
			'plant_edit.location_label' => 'Bereich',
			'plant_edit.delete' => 'Pflanze aus dem Garten entfernen',
			'plant_edit.delete_note' => 'Der Aufgabenverlauf bleibt im Tagebuch.',
			'plant_edit.save' => 'Speichern',
			'plant_detail.not_found' => 'Pflanze nicht gefunden.',
			'plant_detail.history_title' => 'Aufgabenverlauf',
			'plant_detail.history_empty' => 'Noch keine Aufgaben für diese Pflanze.',
			'plant_detail.move' => 'verschieben',
			'plant_detail.assign_area' => 'Bereich zuweisen',
			'area_pick.move_title' => ({required Object name}) => '„${name}“ verschieben',
			'area_pick.choose_title' => 'Bereich wählen',
			'area_pick.note' => 'Eine Pflanze gehört zu einem Bereich (oder keinem). Der Aufgabenverlauf bleibt.',
			'area_pick.none' => 'Kein Bereich',
			'area_pick.current' => 'aktuell',
			'area_pick.new_area' => 'Neuer Bereich',
			'area_pick.duplicate' => 'Diese Pflanze ist bereits im gewählten Bereich.',
			'areas.title' => 'Garten',
			'areas.subtitle' => 'Pflanzen und Rasen',
			'areas.unassigned' => 'Ohne Bereich',
			'areas.last_prefix' => 'zuletzt:',
			'areas.type_garden' => 'Garten',
			'areas.type_lawn' => 'Rasen',
			'areas.type_hedge' => 'Hecke',
			'areas.type_bed' => 'Beet',
			'areas.type_tree' => 'Obstbaum',
			'areas.type_ornamental' => 'Zierpflanzen',
			'areas.type_other' => 'Sonstiges',
			'areas.default_garden_name' => 'Garten',
			'areas.history_title' => 'Aufgabenverlauf',
			'areas.history_empty' => 'Noch keine Aufgaben in diesem Bereich.',
			'areas.plants_section' => 'Pflanzen',
			'areas.add_plant_here' => ({required Object area}) => 'Pflanze zu ${area} hinzufügen',
			'areas.delete_reparent_note' => 'Pflanzen in diesem Bereich wechseln zu „Ohne Bereich“ (sie werden nicht gelöscht).',
			'areas.new_area_inline' => 'Neuer Bereich',
			'areas.empty_title' => 'Dein Garten ist leer',
			'areas.empty_body' => 'Füge deine Pflanzen hinzu. Bereiche (Beete, Rasen) sind optional.',
			'areas.empty_cta_plant' => 'Pflanzen hinzufügen',
			'areas.empty_cta_area' => 'Bereich hinzufügen',
			'areas.action_edit' => 'Bearbeiten',
			'areas.action_delete' => 'Löschen',
			'areas.delete_confirm_title' => 'Bereich löschen?',
			'areas.delete_confirm_body' => 'Aufgaben bleiben erhalten, verlieren aber die Verknüpfung zum Bereich.',
			'areas.form_title_new' => 'Neuer Bereich',
			'areas.form_title_edit' => 'Bereich bearbeiten',
			'areas.form_name' => 'Name',
			'areas.form_name_hint' => 'z. B. Hochbeet 1',
			'areas.form_type' => 'Typ',
			'areas.form_save' => 'Bereich speichern',
			'areas.err_name' => 'Bereichsnamen eingeben.',
			'plants.picker_title' => 'Pflanze auswählen',
			'plants.search_hint' => 'Pflanze suchen…',
			'plants.cat_all' => 'Alle',
			'plants.cat_fruit_tree' => 'Obstbäume',
			'plants.cat_berries' => 'Beeren',
			'plants.cat_vegetable' => 'Gemüse',
			'plants.cat_herbs' => 'Kräuter',
			'plants.cat_ornamental' => 'Zierpflanzen',
			'plants.cat_houseplant' => 'Zimmerpflanzen',
			'plants.cat_lawn' => 'Rasen',
			'plants.from_catalog' => 'Aus dem Katalog',
			'plants.not_found' => 'Nicht gefunden?',
			'plants.custom_add' => ({required Object q}) => '+ Eigene hinzufügen: „${q}“',
			'plants.custom_private' => 'Ein eigener Eintrag ist privat und wird nicht mit der Community geteilt.',
			'plants.add_title' => 'Pflanzen hinzufügen',
			'plants.frequent' => 'Häufig',
			'plants.undo' => 'Rückgängig',
			'plants.done' => 'Fertig',
			'plants.add_to_label' => 'Hinzufügen zu',
			'plants.choose_area' => 'wählen',
			'plants.field_add' => 'Pflanze auswählen',
			'plants.field_empty' => 'Dieser Bereich hat noch keine Pflanzen. Füge unten eine hinzu.',
			'supplies.title' => 'Vorräte',
			'supplies.subtitle' => 'was ich zu Hause habe',
			'supplies.empty' => 'Noch keine Vorräte. Füge welche mit + hinzu.',
			'supplies.low' => 'wenig',
			'supplies.qty' => ({required Object q, required Object unit}) => '~${q}${unit}',
			'supplies.form_new' => 'Neues Mittel',
			'supplies.form_edit' => 'Mittel bearbeiten',
			'supplies.form_name' => 'Name',
			'supplies.form_quantity' => 'Menge',
			'supplies.form_unit' => 'Einheit',
			'supplies.form_threshold' => 'Warnen bei (Schwelle)',
			'supplies.form_save' => 'Speichern',
			'supplies.err_name' => 'Namen des Mittels eingeben.',
			'supplies.add_to_task' => 'Mittel hinzufügen',
			'supplies.pick_new' => 'Neues Mittel',
			'supplies.amount' => 'Verbrauchte Menge',
			'supplies.add_confirm' => 'Hinzufügen',
			'settings.title' => 'Einstellungen',
			'settings.profile_guest' => 'Gast (nicht angemeldet)',
			'settings.sign_in_prompt' => 'Melde dich an, um deine Daten zu sichern',
			'settings.signed_in' => 'Angemeldet — Daten gesichert',
			'settings.section_location' => 'Standort',
			'settings.location_placeholder' => 'Wetter-Standort',
			'settings.section_language' => 'Sprache',
			'settings.section_notifications' => 'Benachrichtigungen',
			'settings.notifications_placeholder' => 'Benachrichtigungen und Erinnerungen',
			'settings.section_suggestions' => 'Vorschläge',
			'settings.suggestions_history_sub' => 'Was vorgeschlagen wurde und wie du reagiert hast',
			'settings.section_garden' => 'Garten',
			'settings.supplies' => '📦 Vorräte & Mittel',
			'settings.supplies_sub' => 'Harnstoff, Algen, Dünger, Geräte',
			'settings.section_account' => 'Konto & Daten',
			'settings.export_data' => 'Daten exportieren (DSGVO)',
			'settings.logout' => 'Abmelden',
			'settings.logout_confirm_title' => 'Abmelden?',
			'settings.logout_confirm_body' => 'Meldet dich ab und löscht lokale Daten von diesem Gerät. Synchronisierte Daten bleiben in der Cloud und kehren zurück, wenn du dich mit demselben Konto erneut anmeldest.',
			'settings.logout_cancel' => 'Abbrechen',
			'settings.logout_offline' => 'Abmelden offline nicht möglich — deine Daten sind noch nicht in der Cloud gesichert. Versuche es erneut, sobald du verbunden bist.',
			'settings.export_share_text' => 'Tendask Datenexport',
			'settings.export_error' => 'Export fehlgeschlagen. Bitte versuche es erneut.',
			'settings.delete_account' => 'Konto und alle Daten löschen',
			'settings.delete_account_confirm_title' => 'Konto löschen?',
			'settings.delete_account_confirm_body' => 'Löscht dein Konto und alle Daten (Aufgaben, Bereiche, Pflanzen, Notizen) endgültig — sowohl in der Cloud als auch auf diesem Gerät. Dies kann nicht rückgängig gemacht werden.',
			'settings.delete_account_confirm' => 'Konto löschen',
			'settings.delete_account_error' => 'Löschen fehlgeschlagen. Versuche es erneut, sobald du verbunden bist.',
			'settings.delete_data' => 'Alle Daten auf diesem Gerät löschen',
			'settings.delete_data_confirm_title' => 'Alle Daten löschen?',
			'settings.delete_data_confirm_body' => 'Löscht alle Daten auf diesem Gerät (Aufgaben, Bereiche, Pflanzen, Notizen) endgültig. Dies kann nicht rückgängig gemacht werden.',
			'settings.delete_data_confirm' => 'Löschen',
			'settings.section_about' => 'Über',
			'settings.privacy_policy' => 'Datenschutzerklärung',
			'weather.cond_clear' => 'Klar',
			'weather.cond_mainly_clear' => 'Überwiegend klar',
			'weather.cond_cloudy' => 'Bewölkt',
			'weather.cond_fog' => 'Nebel',
			'weather.cond_drizzle' => 'Nieselregen',
			'weather.cond_rain' => 'Regen',
			'weather.cond_snow' => 'Schnee',
			'weather.cond_showers' => 'Schauer',
			'weather.cond_thunderstorm' => 'Gewitter',
			'weather.cond_unknown' => '—',
			'weather.band_forecast' => 'Vorhersage',
			'weather.rain_past48h' => 'Regen letzte 48 h:',
			'weather.detail_waiting' => 'Das Wetter wird erfasst, sobald du die Aufgabe als erledigt markierst.',
			'weather.detail_none' => 'Keine Wetteraufnahme (zum Zeitpunkt offline).',
			'weather.home_unavailable' => 'Wetter derzeit nicht verfügbar.',
			'weather.home_retry' => 'Zum Wiederholen tippen',
			'weather.loading' => 'Wetter wird geladen…',
			'weather.updated_at' => ({required Object time}) => 'Aktualisiert ${time}',
			'weather.m_humidity' => 'Luftfeuchte',
			'weather.m_wind' => 'Wind',
			'weather.m_precipitation' => 'Niederschlag',
			'weather.m_soil_temp' => 'Bodentemp.',
			'weather.m_et0' => 'ET₀',
			'weather.m_rain48h' => 'Regen 48 h',
			'weather.m_no_rain' => 'kein Regen',
			'suggestions.actions.plan' => 'Einplanen',
			'suggestions.actions.dismiss' => 'Überspringen',
			'suggestions.actions.already_done' => 'Schon erledigt',
			'suggestions.actions.never' => 'Nicht mehr vorschlagen',
			'suggestions.actions.remove_subject' => 'Habe ich nicht mehr',
			'suggestions.toast.planned' => 'Zu deinen Aufgaben hinzugefügt',
			'suggestions.toast.logged' => 'Als erledigt erfasst',
			'suggestions.disclaimer' => 'Vorschläge sind allgemeine Hinweise — deinen Garten kennst du am besten.',
			'suggestions.done_sheet.title' => 'Wann hast du es gemacht?',
			'suggestions.done_sheet.today' => 'Heute',
			'suggestions.done_sheet.yesterday' => 'Gestern',
			'suggestions.done_sheet.pick' => 'Datum wählen…',
			'suggestions.remove.title' => 'Entfernen?',
			'suggestions.remove.body' => 'Entfernt {subject} aus deinem Garten und stoppt die Vorschläge dazu. Deine bisherigen Einträge bleiben.',
			'suggestions.remove.confirm' => 'Entfernen',
			'suggestions.history_status.planned' => 'Eingeplant',
			'suggestions.history_status.logged' => 'Erfasst',
			'suggestions.history_status.dismissed' => 'Verworfen',
			'suggestions.history_status.muted' => 'Stumm',
			'suggestions.history_status.missed' => 'Verpasst',
			'suggestions.band_title' => 'Vorschläge für dich',
			'suggestions.past_link' => 'Verlauf',
			'suggestions.past_title' => 'Frühere Vorschläge',
			'suggestions.past_intro' => 'Was Tendask vorgeschlagen hat und wie du reagiert hast.',
			'suggestions.past_empty' => 'Noch kein Verlauf. Sobald du auf einen Vorschlag reagierst — einplanen, überspringen oder als erledigt erfassen — erscheint er hier.',
			'suggestions.past_retention' => 'Vorschläge, die älter als ein Jahr sind, werden automatisch entfernt.',
			'suggestions.cadence.overdue.title' => '{task} ist fällig',
			'suggestions.cadence.overdue.body' => '{subject}: ca. {days_overdue} Tage über dem üblichen Rhythmus (~{cadence_days} Tage).',
			'suggestions.history.anniversary.title' => '{task} — vor einem Jahr',
			'suggestions.history.anniversary.body' => 'Letztes Jahr um den {last_year_date} — {task} bei {subject}. Wieder fällig?',
			'suggestions.weather.window_open.title' => '{task}: gutes Zeitfenster',
			'suggestions.weather.window_open.body' => 'Für {subject} steht eine trockene Phase an — ein guter Zeitpunkt.',
			'suggestions.community.most_started.title' => '{task} in der Nähe',
			'suggestions.community.most_started.body' => 'Etwa {percent} % der Gärtner in deiner Nähe haben das diese Saison schon begonnen.',
			'suggestions.lawn.mow_due.title' => 'Mähen fällig',
			'suggestions.lawn.mow_due.body' => '{subject} ist bereit zum Mähen.',
			'suggestions.lawn.water_drought.title' => 'Gießen bei Trockenheit',
			'suggestions.lawn.water_drought.body' => '{subject} braucht bei trockenem Wetter eventuell Wasser.',
			'suggestions.lawn.fertilize_spring.title' => 'Frühjahrsdüngung',
			'suggestions.lawn.fertilize_spring.body' => 'Dünge {subject} für die Saison — am besten bis etwa {window_end_date}.',
			'suggestions.lawn.fertilize_autumn.title' => 'Herbstdüngung',
			'suggestions.lawn.fertilize_autumn.body' => 'Gib {subject} vor dem Winter eine Herbstdüngung — Zeitfenster bis ~{window_end_date}.',
			'suggestions.lawn.lime.title' => 'Rasen kalken',
			'suggestions.lawn.lime.body' => 'Kalke {subject} bei saurem Boden — bis etwa {window_end_date}.',
			'suggestions.lawn.moss_control.title' => 'Moosbekämpfung',
			'suggestions.lawn.moss_control.body' => 'Bekämpfe Moos in {subject} — Zeitfenster bis ~{window_end_date}.',
			'suggestions.lawn.weed_control.title' => 'Unkrautbekämpfung',
			'suggestions.lawn.weed_control.body' => 'Geh das Unkraut in {subject} an — am besten bis etwa {window_end_date}.',
			'suggestions.lawn.overseed_spring.title' => 'Nachsaat (Frühjahr)',
			'suggestions.lawn.overseed_spring.body' => 'Säe kahle Stellen in {subject} nach — bis etwa {window_end_date}.',
			'suggestions.lawn.overseed_autumn.title' => 'Nachsaat (Herbst)',
			'suggestions.lawn.overseed_autumn.body' => 'Übersäe {subject} im Herbst — Zeitfenster bis ~{window_end_date}.',
			'suggestions.lawn.scarify_spring.title' => 'Vertikutieren (Frühjahr)',
			'suggestions.lawn.scarify_spring.body' => 'Vertikutiere {subject} gegen Rasenfilz — bis etwa {window_end_date}.',
			'suggestions.lawn.scarify_autumn.title' => 'Vertikutieren (Herbst)',
			'suggestions.lawn.scarify_autumn.body' => 'Vertikutiere {subject} im Herbst — Zeitfenster bis ~{window_end_date}.',
			'suggestions.lawn.aerate.title' => 'Aerifizieren',
			'suggestions.lawn.aerate.body' => 'Lüfte {subject} gegen Verdichtung — bis etwa {window_end_date}.',
			'suggestions.lawn.roll.title' => 'Rasen walzen',
			'suggestions.lawn.roll.body' => 'Walze {subject} nach dem Winter — Zeitfenster bis ~{window_end_date}.',
			'suggestions.lawn.topdress.title' => 'Topdressing',
			'suggestions.lawn.topdress.body' => 'Sande {subject} ab und ebne ein — bis etwa {window_end_date}.',
			'suggestions.fruit_tree.fertilize_spring.title' => 'Frühjahrsdüngung',
			'suggestions.fruit_tree.fertilize_spring.body' => 'Dünge deinen {subject} zu Wachstumsbeginn — bis etwa {window_end_date}.',
			'suggestions.fruit_tree.prune_winter.title' => 'Winterschnitt',
			'suggestions.fruit_tree.prune_winter.body' => 'Schneide {subject} in der Ruhephase — Zeitfenster bis ~{window_end_date}.',
			'suggestions.fruit_tree.treat_dormant.title' => 'Winterspritzung',
			'suggestions.fruit_tree.treat_dormant.body' => 'Behandle {subject} mit einer Winterspritzung — bis etwa {window_end_date}.',
			'suggestions.fruit_tree.mulch.title' => 'Mulchen',
			'suggestions.fruit_tree.mulch.body' => 'Mulche um {subject}, um Feuchtigkeit zu halten — bis etwa {window_end_date}.',
			'suggestions.fruit_tree.thin_fruit.title' => 'Früchte ausdünnen',
			'suggestions.fruit_tree.thin_fruit.body' => 'Dünne die Fruchtansätze von {subject} aus — Zeitfenster bis ~{window_end_date}.',
			'suggestions.fruit_tree.graft_spring.title' => 'Frühjahrsveredelung',
			'suggestions.fruit_tree.graft_spring.body' => 'Veredle {subject} beim Saftaufstieg — bis etwa {window_end_date}.',
			'suggestions.fruit_tree.graft_budding.title' => 'Sommerokulation',
			'suggestions.fruit_tree.graft_budding.body' => 'Okuliere {subject} im Spätsommer — Zeitfenster bis ~{window_end_date}.',
			'suggestions.berries.prune_winter.title' => 'Winterschnitt',
			'suggestions.berries.prune_winter.body' => 'Schneide {subject} in der Ruhephase — bis etwa {window_end_date}.',
			'suggestions.berries.fertilize_spring.title' => 'Frühjahrsdüngung',
			'suggestions.berries.fertilize_spring.body' => 'Dünge {subject} zu Wachstumsbeginn — bis etwa {window_end_date}.',
			_ => null,
		} ?? switch (path) {
			'suggestions.berries.mulch.title' => 'Mulchen',
			'suggestions.berries.mulch.body' => 'Mulche {subject} für kühle, feuchte Wurzeln — bis etwa {window_end_date}.',
			'suggestions.berries.treat_dormant.title' => 'Winterspritzung',
			'suggestions.berries.treat_dormant.body' => 'Behandle {subject} mit einer Winterspritzung — bis etwa {window_end_date}.',
			'suggestions.vegetable.start_seedlings.title' => 'Anzucht starten',
			'suggestions.vegetable.start_seedlings.body' => 'Säe {subject} drinnen für das spätere Auspflanzen — bis etwa {window_end_date}.',
			'suggestions.vegetable.prick_out.title' => 'Pikieren',
			'suggestions.vegetable.prick_out.body' => '{subject} wurde vor {days_since} Tagen ausgesät — pikiere die Sämlinge in Töpfe.',
			'suggestions.vegetable.harden_off.title' => 'Abhärten',
			'suggestions.vegetable.harden_off.body' => 'Gewöhne {subject} vor dem Auspflanzen draußen ab — Zeitfenster bis ~{window_end_date}.',
			'suggestions.vegetable.plant_out.title' => 'Auspflanzen',
			'suggestions.vegetable.plant_out.body' => 'Pflanze {subject} aus, sobald kein Frost mehr droht — um {frost_date}.',
			'suggestions.vegetable.transplant.title' => 'Umpflanzen',
			'suggestions.vegetable.transplant.body' => 'Setze {subject} nach dem Frost an den endgültigen Platz — um {frost_date}.',
			'suggestions.vegetable.sow_direct.title' => 'Direktsaat',
			'suggestions.vegetable.sow_direct.body' => 'Säe {subject} direkt ins Freie, sobald es mild wird — Zeitfenster bis ~{window_end_date}.',
			'suggestions.vegetable.fertilize_season.title' => 'Düngen',
			'suggestions.vegetable.fertilize_season.body' => 'Dünge {subject} während der Wachstumszeit.',
			'suggestions.vegetable.treat_window.title' => 'Kontrollieren',
			'suggestions.vegetable.treat_window.body' => 'Prüfe {subject} und behandle bei Bedarf — am besten bei trockenem Wetter.',
			'suggestions.herbs.start_seedlings.title' => 'Anzucht starten',
			'suggestions.herbs.start_seedlings.body' => 'Säe {subject} drinnen für einen Vorsprung — bis etwa {window_end_date}.',
			'suggestions.herbs.sow_direct.title' => 'Direktsaat',
			'suggestions.herbs.sow_direct.body' => 'Säe {subject} direkt ins Freie, sobald es mild wird — Zeitfenster bis ~{window_end_date}.',
			'suggestions.herbs.plant_out.title' => 'Auspflanzen',
			'suggestions.herbs.plant_out.body' => 'Pflanze {subject} aus, sobald kein Frost mehr droht — um {frost_date}.',
			'suggestions.tomato.start_seedlings.title' => 'Anzucht starten',
			'suggestions.tomato.start_seedlings.body' => 'Säe {subject} drinnen für einen Vorsprung — bis etwa {window_end_date}.',
			'suggestions.tomato.prick_out.title' => 'Pikieren',
			'suggestions.tomato.prick_out.body' => '{subject} wurde vor {days_since} Tagen ausgesät — pikiere die Sämlinge in Töpfe.',
			'suggestions.tomato.harden_off.title' => 'Abhärten',
			'suggestions.tomato.harden_off.body' => 'Gewöhne {subject} vor dem Auspflanzen draußen ab — Zeitfenster bis ~{window_end_date}.',
			'suggestions.tomato.transplant.title' => 'Umpflanzen',
			'suggestions.tomato.transplant.body' => '{subject} wächst seit {days_since} Tagen — an den endgültigen Platz setzen.',
			'suggestions.tomato.stake.title' => 'Stützen',
			'suggestions.tomato.stake.body' => '{subject}: {days_since} Tage Wachstum — Stab oder Stütze anbringen.',
			'suggestions.shrub.prune_spring.title' => 'Frühjahrsschnitt',
			'suggestions.shrub.prune_spring.body' => 'Schneide {subject} nach Bedarf — bis etwa {window_end_date}.',
			'suggestions.shrub.overwinter.title' => 'Winterschutz',
			'suggestions.shrub.overwinter.body' => 'Schütze {subject} vor dem ersten starken Frost — bis etwa {window_end_date}.',
			'suggestions.hedge.prune_early_summer.title' => 'Frühsommerschnitt',
			'suggestions.hedge.prune_early_summer.body' => 'Schneide {subject} in Form — Zeitfenster bis ~{window_end_date}.',
			'suggestions.hedge.prune_late_summer.title' => 'Spätsommerschnitt',
			'suggestions.hedge.prune_late_summer.body' => 'Gib {subject} vor dem Herbst einen letzten Schnitt — bis etwa {window_end_date}.',
			'suggestions.conifer.prune.title' => 'Rückschnitt',
			'suggestions.conifer.prune.body' => 'Schneide {subject} leicht ins neue Wachstum — bis etwa {window_end_date}.',
			'suggestions.houseplant.repot.title' => 'Umtopfen',
			'suggestions.houseplant.repot.body' => 'Topfe {subject} bei Wachstumsbeginn um — Zeitfenster bis ~{window_end_date}.',
			'suggestions.houseplant.fertilize_season.title' => 'Düngen',
			'suggestions.houseplant.fertilize_season.body' => 'Dünge {subject} während der aktiven Wachstumszeit.',
			'suggestions.houseplant.overwinter.title' => 'Reinholen',
			'suggestions.houseplant.overwinter.body' => 'Hole {subject} vor dem ersten Frost ins Haus — bis etwa {window_end_date}.',
			'suggestions.blueberry.prune.title' => 'Schnitt',
			'suggestions.blueberry.prune.body' => 'Schneide {subject} in der Ruhephase — bis etwa {window_end_date}.',
			'suggestions.cherry_laurel.prune_late_spring.title' => 'Spätfrühlingsschnitt',
			'suggestions.cherry_laurel.prune_late_spring.body' => 'Schneide {subject} nach dem ersten Austrieb — Zeitfenster bis ~{window_end_date}.',
			'suggestions.cherry_laurel.prune_late_summer.title' => 'Spätsommerschnitt',
			'suggestions.cherry_laurel.prune_late_summer.body' => 'Schneide {subject} ein zweites Mal — bis etwa {window_end_date}.',
			'suggestions.hydrangea.prune_old_wood.title' => 'Schnitt (altes Holz)',
			'suggestions.hydrangea.prune_old_wood.body' => 'Verblühtes ausputzen und {subject} am alten Holz nach der Blüte schneiden — bis etwa {window_end_date}.',
			'suggestions.hydrangea.prune_new_wood.title' => 'Schnitt (neues Holz)',
			'suggestions.hydrangea.prune_new_wood.body' => 'Schneide {subject} am neuen Holz im Spätwinter zurück — bis etwa {window_end_date}.',
			'suggestions.peach.prune_spring.title' => 'Frühjahrsschnitt',
			'suggestions.peach.prune_spring.body' => 'Schneide {subject} beim Knospenschwellen gegen Kräuselkrankheit — bis etwa {window_end_date}.',
			'suggestions.raspberry.prune_late_winter.title' => 'Spätwinterschnitt',
			'suggestions.raspberry.prune_late_winter.body' => 'Schneide die Ruten von {subject} vor dem Austrieb — bis etwa {window_end_date}.',
			'suggestions.raspberry.prune_after_harvest.title' => 'Schnitt nach der Ernte',
			'suggestions.raspberry.prune_after_harvest.body' => '{subject} hat vor {days_since} Tagen getragen — schneide die alten Ruten heraus.',
			'suggestions.rose.prune_spring.title' => 'Frühjahrsschnitt',
			'suggestions.rose.prune_spring.body' => 'Schneide {subject} beim Austrieb — bis etwa {window_end_date}.',
			'suggestions.rose.overwinter.title' => 'Winterschutz',
			'suggestions.rose.overwinter.body' => 'Häufle {subject} an oder schütze sie vor starkem Frost — bis etwa {window_end_date}.',
			'suggestions.cucumber.sow_direct.title' => 'Direktsaat',
			'suggestions.cucumber.sow_direct.body' => 'Säe {subject} ins Freie, sobald es warm und frostfrei ist — um {frost_date}.',
			'suggestions.zucchini.sow_direct.title' => 'Direktsaat',
			'suggestions.zucchini.sow_direct.body' => 'Säe {subject} nach dem Frost ins Freie — um {frost_date}.',
			_ => null,
		};
	}
}

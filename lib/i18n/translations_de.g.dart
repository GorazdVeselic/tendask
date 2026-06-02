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
	@override late final _Translations$nav$de nav = _Translations$nav$de._(_root);
	@override late final _Translations$home$de home = _Translations$home$de._(_root);
	@override late final _Translations$common$de common = _Translations$common$de._(_root);
	@override late final _Translations$journal$de journal = _Translations$journal$de._(_root);
	@override late final _Translations$quick_log$de quick_log = _Translations$quick_log$de._(_root);
	@override late final _Translations$notes$de notes = _Translations$notes$de._(_root);
	@override late final _Translations$task_detail$de task_detail = _Translations$task_detail$de._(_root);
	@override late final _Translations$tasks_list$de tasks_list = _Translations$tasks_list$de._(_root);
	@override late final _Translations$task_form$de task_form = _Translations$task_form$de._(_root);
	@override late final _Translations$areas$de areas = _Translations$areas$de._(_root);
	@override late final _Translations$plants$de plants = _Translations$plants$de._(_root);
	@override late final _Translations$supplies$de supplies = _Translations$supplies$de._(_root);
	@override late final _Translations$settings$de settings = _Translations$settings$de._(_root);
}

// Path: nav
class _Translations$nav$de extends Translations$nav$sl {
	_Translations$nav$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get home => 'Startseite';
	@override String get journal => 'Tagebuch';
	@override String get areas => 'Bereiche';
	@override String get tasks => 'Aufgaben';
}

// Path: home
class _Translations$home$de extends Translations$home$sl {
	_Translations$home$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Guten Tag 🌿';
	@override String get today => 'Heute';
	@override String get recent => 'Zuletzt';
	@override String get no_tasks_today => 'Heute keine geplanten Aufgaben.';
	@override String get no_recent => 'Noch keine erledigten Aufgaben.';
	@override String get weather_placeholder => 'Wetter kommt in M4.';
}

// Path: common
class _Translations$common$de extends Translations$common$sl {
	_Translations$common$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get today => 'Heute';
	@override String get today_lower => 'heute';
	@override String get yesterday => 'gestern';
}

// Path: journal
class _Translations$journal$de extends Translations$journal$sl {
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
	@override String get timeline => 'Zeitlinie';
	@override String get month_view => 'Monat';
	@override String get month_hint => '💡 Tippe auf einen Tag, um eine Aufgabe hinzuzufügen (vergangen oder geplant).';
	@override String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '{n} Aufgabe diesen Monat',
		other: '{n} Aufgaben diesen Monat',
	);
}

// Path: quick_log
class _Translations$quick_log$de extends Translations$quick_log$sl {
	_Translations$quick_log$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Schnell erfassen';
	@override String get advanced => 'Erweitert ›';
	@override String get note_card_title => 'Keine Aufgabe, nur eine Notiz?';
	@override String get note_card_sub => 'Gedanke, Beobachtung, Krankheit…';
	@override String get note_card_action => 'Notiz ›';
	@override String get what => 'Was hast du gemacht?';
	@override String get when => 'Wann';
	@override String get today => 'Heute';
	@override String get yesterday => 'Gestern';
	@override String get pick_date => 'Datum…';
	@override String get where => 'Wo';
	@override String get no_areas => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.';
	@override String get more => 'Mehr (optional)';
	@override String get add_plant => '🌿 Pflanze hinzufügen';
	@override String get add_supply => '🧪 Mittel hinzufügen';
	@override String get add_reminder => '🔔 Erinnerung hinzufügen';
	@override String get note_label => 'Notiz (optional)';
	@override String get note_hint => 'z.B. 100g Harnstoff pro 16L';
	@override String get save => 'Aufgabe speichern';
	@override String get err_type => 'Aufgabentyp auswählen.';
	@override String get err_area => 'Bereich auswählen.';
}

// Path: notes
class _Translations$notes$de extends Translations$notes$sl {
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
class _Translations$task_detail$de extends Translations$task_detail$sl {
	_Translations$task_detail$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get section_weather => 'Wetteraufnahme';
	@override String get weather_placeholder => 'Wetteraufnahme wird in M4 verfügbar sein.';
	@override String get section_details => 'Details';
	@override String get label_area => 'Bereich';
	@override String get label_plant => 'Pflanze';
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
class _Translations$tasks_list$de extends Translations$tasks_list$sl {
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
		other: '{n} Tage überfällig',
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

// Path: task_form
class _Translations$task_form$de extends Translations$task_form$sl {
	_Translations$task_form$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Neue Aufgabe';
	@override String get title_edit => 'Aufgabe bearbeiten';
	@override String get what => 'Was';
	@override String get what_hint => 'Aufgabentyp auswählen';
	@override String get when => 'Wann';
	@override String get status => 'Status';
	@override String get status_waiting => 'Ausstehend';
	@override String get status_done => 'Erledigt';
	@override String get area => 'Bereich';
	@override String get no_areas => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.';
	@override String get plant => 'Pflanze';
	@override String get plant_hint => '(für Schnitt, Behandlung, Ernte…)';
	@override String get plant_add => 'Pflanze auswählen';
	@override String get plant_note => 'Mit Pflanze verknüpfen, nicht nur Bereich.';
	@override String get plant_select => 'Pflanze auswählen';
	@override String get plant_none => 'Dieser Bereich hat noch keine Pflanzen. Füge unten eine hinzu.';
	@override String get supplies => 'Verbrauchte Mittel';
	@override String get supplies_add => '+ Mittel hinzufügen';
	@override String get reminders => 'Erinnerung (optional)';
	@override String get reminders_add => '+ Erinnerung hinzufügen';
	@override String get recurrence => 'Wiederholung';
	@override String get recurrence_once => 'Einmalig';
	@override String get recurrence_weekly => 'Wöchentlich';
	@override String get recurrence_seasonal => 'Saisonal';
	@override String get note => 'Notiz (optional)';
	@override String get note_hint => 'Morgens, vor dem erwarteten Regen.';
	@override String get save => 'Aufgabe speichern';
	@override String get err_type => 'Aufgabentyp auswählen.';
	@override String get err_area => 'Bereich auswählen.';
}

// Path: areas
class _Translations$areas$de extends Translations$areas$sl {
	_Translations$areas$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bereiche';
	@override String get subtitle => 'mein Grundstück';
	@override String get empty => 'Noch keine Bereiche. Füge den ersten mit + hinzu.';
	@override String get last_prefix => 'zuletzt:';
	@override String get type_lawn => 'Rasen';
	@override String get type_hedge => 'Hecke';
	@override String get type_bed => 'Beet';
	@override String get type_tree => 'Obstbaum';
	@override String get type_ornamental => 'Zierpflanzen';
	@override String get type_other => 'Sonstiges';
	@override String get history_title => 'Aufgabenverlauf';
	@override String get history_empty => 'Noch keine Aufgaben in diesem Bereich.';
	@override String get action_edit => 'Bearbeiten';
	@override String get action_delete => 'Löschen';
	@override String get delete_confirm_title => 'Bereich löschen?';
	@override String get delete_confirm_body => 'Aufgaben bleiben erhalten, verlieren aber die Verknüpfung zum Bereich.';
	@override String get form_title_new => 'Neuer Bereich';
	@override String get form_title_edit => 'Bereich bearbeiten';
	@override String get form_name => 'Name';
	@override String get form_name_hint => 'z. B. Hochbeet 1';
	@override String get form_type => 'Typ';
	@override String get form_plants => 'Pflanzen im Bereich';
	@override String get form_plants_add => 'Pflanze hinzufügen';
	@override String get form_plants_note => 'Aufgaben (Schnitt, Behandlung, Ernte) werden mit der gewählten Pflanze verknüpft.';
	@override String get form_save => 'Bereich speichern';
	@override String get err_name => 'Bereichsnamen eingeben.';
	@override String get plants_empty => 'Noch keine Pflanzen.';
	@override String get plant_remove => 'Entfernen';
}

// Path: plants
class _Translations$plants$de extends Translations$plants$sl {
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
	@override String get cat_lawn => 'Rasen';
	@override String get from_catalog => 'Aus dem Katalog';
	@override String get not_found => 'Nicht gefunden?';
	@override String custom_add({required Object q}) => '+ Eigene hinzufügen: „${q}“';
	@override String get custom_private => 'Ein eigener Eintrag ist privat und wird nicht mit der Community geteilt.';
}

// Path: supplies
class _Translations$supplies$de extends Translations$supplies$sl {
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
class _Translations$settings$de extends Translations$settings$sl {
	_Translations$settings$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Einstellungen';
	@override String get profile_guest => 'Gast (nicht angemeldet)';
	@override String get section_location => 'Standort';
	@override String get location_placeholder => 'Wetter-Standort';
	@override String get section_language => 'Sprache';
	@override String get section_notifications => 'Benachrichtigungen';
	@override String get notifications_placeholder => 'Benachrichtigungen und Erinnerungen';
	@override String get section_garden => 'Garten';
	@override String get supplies => '📦 Vorräte & Mittel';
	@override String get supplies_sub => 'Harnstoff, Algen, Dünger, Geräte';
	@override String get areas => '🪴 Bereiche';
	@override String get areas_sub => 'Rasen, Hecken, Beete';
	@override String get section_account => 'Konto & Daten';
	@override String get units => 'Einheiten';
	@override String get export_data => 'Daten exportieren (DSGVO)';
	@override String get logout => 'Abmelden';
	@override String get delete_account => 'Konto und alle Daten löschen';
	@override String get coming_soon => 'Demnächst';
	@override String get version => 'Tendask · v1 (MVP)';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsDe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.home' => 'Startseite',
			'nav.journal' => 'Tagebuch',
			'nav.areas' => 'Bereiche',
			'nav.tasks' => 'Aufgaben',
			'home.greeting' => 'Guten Tag 🌿',
			'home.today' => 'Heute',
			'home.recent' => 'Zuletzt',
			'home.no_tasks_today' => 'Heute keine geplanten Aufgaben.',
			'home.no_recent' => 'Noch keine erledigten Aufgaben.',
			'home.weather_placeholder' => 'Wetter kommt in M4.',
			'common.today' => 'Heute',
			'common.today_lower' => 'heute',
			'common.yesterday' => 'gestern',
			'journal.title' => 'Tagebuch',
			'journal.subtitle' => 'Gartentagebuch',
			'journal.filter_all' => 'Alle',
			'journal.filter_tasks' => '✓ Aufgaben',
			'journal.filter_notes' => '✍️ Notizen',
			'journal.empty' => 'Noch keine Einträge.',
			'journal.empty_tasks' => 'Keine erledigten Aufgaben.',
			'journal.empty_notes' => 'Noch keine Notizen.',
			'journal.timeline' => 'Zeitlinie',
			'journal.month_view' => 'Monat',
			'journal.month_hint' => '💡 Tippe auf einen Tag, um eine Aufgabe hinzuzufügen (vergangen oder geplant).',
			'journal.month_count' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '{n} Aufgabe diesen Monat', other: '{n} Aufgaben diesen Monat', ), 
			'quick_log.title' => 'Schnell erfassen',
			'quick_log.advanced' => 'Erweitert ›',
			'quick_log.note_card_title' => 'Keine Aufgabe, nur eine Notiz?',
			'quick_log.note_card_sub' => 'Gedanke, Beobachtung, Krankheit…',
			'quick_log.note_card_action' => 'Notiz ›',
			'quick_log.what' => 'Was hast du gemacht?',
			'quick_log.when' => 'Wann',
			'quick_log.today' => 'Heute',
			'quick_log.yesterday' => 'Gestern',
			'quick_log.pick_date' => 'Datum…',
			'quick_log.where' => 'Wo',
			'quick_log.no_areas' => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.',
			'quick_log.more' => 'Mehr (optional)',
			'quick_log.add_plant' => '🌿 Pflanze hinzufügen',
			'quick_log.add_supply' => '🧪 Mittel hinzufügen',
			'quick_log.add_reminder' => '🔔 Erinnerung hinzufügen',
			'quick_log.note_label' => 'Notiz (optional)',
			'quick_log.note_hint' => 'z.B. 100g Harnstoff pro 16L',
			'quick_log.save' => 'Aufgabe speichern',
			'quick_log.err_type' => 'Aufgabentyp auswählen.',
			'quick_log.err_area' => 'Bereich auswählen.',
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
			'task_detail.weather_placeholder' => 'Wetteraufnahme wird in M4 verfügbar sein.',
			'task_detail.section_details' => 'Details',
			'task_detail.label_area' => 'Bereich',
			'task_detail.label_plant' => 'Pflanze',
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
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '1 Tag überfällig', other: '{n} Tage überfällig', ), 
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
			'task_form.title_new' => 'Neue Aufgabe',
			'task_form.title_edit' => 'Aufgabe bearbeiten',
			'task_form.what' => 'Was',
			'task_form.what_hint' => 'Aufgabentyp auswählen',
			'task_form.when' => 'Wann',
			'task_form.status' => 'Status',
			'task_form.status_waiting' => 'Ausstehend',
			'task_form.status_done' => 'Erledigt',
			'task_form.area' => 'Bereich',
			'task_form.no_areas' => 'Keine Bereiche — füge sie im Bereich-Abschnitt hinzu.',
			'task_form.plant' => 'Pflanze',
			'task_form.plant_hint' => '(für Schnitt, Behandlung, Ernte…)',
			'task_form.plant_add' => 'Pflanze auswählen',
			'task_form.plant_note' => 'Mit Pflanze verknüpfen, nicht nur Bereich.',
			'task_form.plant_select' => 'Pflanze auswählen',
			'task_form.plant_none' => 'Dieser Bereich hat noch keine Pflanzen. Füge unten eine hinzu.',
			'task_form.supplies' => 'Verbrauchte Mittel',
			'task_form.supplies_add' => '+ Mittel hinzufügen',
			'task_form.reminders' => 'Erinnerung (optional)',
			'task_form.reminders_add' => '+ Erinnerung hinzufügen',
			'task_form.recurrence' => 'Wiederholung',
			'task_form.recurrence_once' => 'Einmalig',
			'task_form.recurrence_weekly' => 'Wöchentlich',
			'task_form.recurrence_seasonal' => 'Saisonal',
			'task_form.note' => 'Notiz (optional)',
			'task_form.note_hint' => 'Morgens, vor dem erwarteten Regen.',
			'task_form.save' => 'Aufgabe speichern',
			'task_form.err_type' => 'Aufgabentyp auswählen.',
			'task_form.err_area' => 'Bereich auswählen.',
			'areas.title' => 'Bereiche',
			'areas.subtitle' => 'mein Grundstück',
			'areas.empty' => 'Noch keine Bereiche. Füge den ersten mit + hinzu.',
			'areas.last_prefix' => 'zuletzt:',
			'areas.type_lawn' => 'Rasen',
			'areas.type_hedge' => 'Hecke',
			'areas.type_bed' => 'Beet',
			'areas.type_tree' => 'Obstbaum',
			'areas.type_ornamental' => 'Zierpflanzen',
			'areas.type_other' => 'Sonstiges',
			'areas.history_title' => 'Aufgabenverlauf',
			'areas.history_empty' => 'Noch keine Aufgaben in diesem Bereich.',
			'areas.action_edit' => 'Bearbeiten',
			'areas.action_delete' => 'Löschen',
			'areas.delete_confirm_title' => 'Bereich löschen?',
			'areas.delete_confirm_body' => 'Aufgaben bleiben erhalten, verlieren aber die Verknüpfung zum Bereich.',
			'areas.form_title_new' => 'Neuer Bereich',
			'areas.form_title_edit' => 'Bereich bearbeiten',
			'areas.form_name' => 'Name',
			'areas.form_name_hint' => 'z. B. Hochbeet 1',
			'areas.form_type' => 'Typ',
			'areas.form_plants' => 'Pflanzen im Bereich',
			'areas.form_plants_add' => 'Pflanze hinzufügen',
			'areas.form_plants_note' => 'Aufgaben (Schnitt, Behandlung, Ernte) werden mit der gewählten Pflanze verknüpft.',
			'areas.form_save' => 'Bereich speichern',
			'areas.err_name' => 'Bereichsnamen eingeben.',
			'areas.plants_empty' => 'Noch keine Pflanzen.',
			'areas.plant_remove' => 'Entfernen',
			'plants.picker_title' => 'Pflanze auswählen',
			'plants.search_hint' => 'Pflanze suchen…',
			'plants.cat_all' => 'Alle',
			'plants.cat_fruit_tree' => 'Obstbäume',
			'plants.cat_berries' => 'Beeren',
			'plants.cat_vegetable' => 'Gemüse',
			'plants.cat_herbs' => 'Kräuter',
			'plants.cat_ornamental' => 'Zierpflanzen',
			'plants.cat_lawn' => 'Rasen',
			'plants.from_catalog' => 'Aus dem Katalog',
			'plants.not_found' => 'Nicht gefunden?',
			'plants.custom_add' => ({required Object q}) => '+ Eigene hinzufügen: „${q}“',
			'plants.custom_private' => 'Ein eigener Eintrag ist privat und wird nicht mit der Community geteilt.',
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
			'settings.section_location' => 'Standort',
			'settings.location_placeholder' => 'Wetter-Standort',
			'settings.section_language' => 'Sprache',
			'settings.section_notifications' => 'Benachrichtigungen',
			'settings.notifications_placeholder' => 'Benachrichtigungen und Erinnerungen',
			'settings.section_garden' => 'Garten',
			'settings.supplies' => '📦 Vorräte & Mittel',
			'settings.supplies_sub' => 'Harnstoff, Algen, Dünger, Geräte',
			'settings.areas' => '🪴 Bereiche',
			'settings.areas_sub' => 'Rasen, Hecken, Beete',
			'settings.section_account' => 'Konto & Daten',
			'settings.units' => 'Einheiten',
			'settings.export_data' => 'Daten exportieren (DSGVO)',
			'settings.logout' => 'Abmelden',
			'settings.delete_account' => 'Konto und alle Daten löschen',
			'settings.coming_soon' => 'Demnächst',
			'settings.version' => 'Tendask · v1 (MVP)',
			_ => null,
		};
	}
}

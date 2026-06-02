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
	@override late final _Translations$quick_log$de quick_log = _Translations$quick_log$de._(_root);
	@override late final _Translations$task_form$de task_form = _Translations$task_form$de._(_root);
}

// Path: nav
class _Translations$nav$de extends Translations$nav$sl {
	_Translations$nav$de._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get home => 'Startseite';
	@override String get journal => 'Tagebuch';
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
	@override String get today => 'heute';
	@override String get yesterday => 'gestern';
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
	@override String get plant_add => '+ Pflanze auswählen';
	@override String get plant_note => 'Mit Pflanze verknüpfen, nicht nur Bereich.';
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
			'nav.tasks' => 'Aufgaben',
			'home.greeting' => 'Guten Tag 🌿',
			'home.today' => 'Heute',
			'home.recent' => 'Zuletzt',
			'home.no_tasks_today' => 'Heute keine geplanten Aufgaben.',
			'home.no_recent' => 'Noch keine erledigten Aufgaben.',
			'home.weather_placeholder' => 'Wetter kommt in M4.',
			'common.today' => 'heute',
			'common.yesterday' => 'gestern',
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
			'task_form.plant_add' => '+ Pflanze auswählen',
			'task_form.plant_note' => 'Mit Pflanze verknüpfen, nicht nur Bereich.',
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
			_ => null,
		};
	}
}

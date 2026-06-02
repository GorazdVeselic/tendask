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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$nav$en nav = _Translations$nav$en._(_root);
	@override late final _Translations$home$en home = _Translations$home$en._(_root);
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$quick_log$en quick_log = _Translations$quick_log$en._(_root);
}

// Path: nav
class _Translations$nav$en extends Translations$nav$sl {
	_Translations$nav$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Home';
	@override String get journal => 'Journal';
	@override String get tasks => 'Tasks';
}

// Path: home
class _Translations$home$en extends Translations$home$sl {
	_Translations$home$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Good day 🌿';
	@override String get today => 'Today';
	@override String get recent => 'Recent';
	@override String get no_tasks_today => 'No tasks planned for today.';
	@override String get no_recent => 'No completed tasks yet.';
	@override String get weather_placeholder => 'Weather coming in M4.';
}

// Path: common
class _Translations$common$en extends Translations$common$sl {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get today => 'today';
	@override String get yesterday => 'yesterday';
}

// Path: quick_log
class _Translations$quick_log$en extends Translations$quick_log$sl {
	_Translations$quick_log$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quick Log';
	@override String get advanced => 'Advanced ›';
	@override String get note_card_title => 'No task, just a note?';
	@override String get note_card_sub => 'Thought, observation, disease…';
	@override String get note_card_action => 'Note ›';
	@override String get what => 'What did you do?';
	@override String get when => 'When';
	@override String get today => 'Today';
	@override String get yesterday => 'Yesterday';
	@override String get pick_date => 'Date…';
	@override String get where => 'Where';
	@override String get no_areas => 'No areas yet — add them in the Areas section.';
	@override String get more => 'More (optional)';
	@override String get add_plant => '🌿 Add plant';
	@override String get add_supply => '🧪 Add supply';
	@override String get add_reminder => '🔔 Add reminder';
	@override String get note_label => 'Note (optional)';
	@override String get note_hint => 'e.g. 100g urea per 16L';
	@override String get save => 'Save task';
	@override String get err_type => 'Select a task type.';
	@override String get err_area => 'Select an area.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav.home' => 'Home',
			'nav.journal' => 'Journal',
			'nav.tasks' => 'Tasks',
			'home.greeting' => 'Good day 🌿',
			'home.today' => 'Today',
			'home.recent' => 'Recent',
			'home.no_tasks_today' => 'No tasks planned for today.',
			'home.no_recent' => 'No completed tasks yet.',
			'home.weather_placeholder' => 'Weather coming in M4.',
			'common.today' => 'today',
			'common.yesterday' => 'yesterday',
			'quick_log.title' => 'Quick Log',
			'quick_log.advanced' => 'Advanced ›',
			'quick_log.note_card_title' => 'No task, just a note?',
			'quick_log.note_card_sub' => 'Thought, observation, disease…',
			'quick_log.note_card_action' => 'Note ›',
			'quick_log.what' => 'What did you do?',
			'quick_log.when' => 'When',
			'quick_log.today' => 'Today',
			'quick_log.yesterday' => 'Yesterday',
			'quick_log.pick_date' => 'Date…',
			'quick_log.where' => 'Where',
			'quick_log.no_areas' => 'No areas yet — add them in the Areas section.',
			'quick_log.more' => 'More (optional)',
			'quick_log.add_plant' => '🌿 Add plant',
			'quick_log.add_supply' => '🧪 Add supply',
			'quick_log.add_reminder' => '🔔 Add reminder',
			'quick_log.note_label' => 'Note (optional)',
			'quick_log.note_hint' => 'e.g. 100g urea per 16L',
			'quick_log.save' => 'Save task',
			'quick_log.err_type' => 'Select a task type.',
			'quick_log.err_area' => 'Select an area.',
			_ => null,
		};
	}
}

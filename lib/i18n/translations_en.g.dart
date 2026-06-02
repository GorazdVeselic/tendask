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
	@override late final _Translations$journal$en journal = _Translations$journal$en._(_root);
	@override late final _Translations$quick_log$en quick_log = _Translations$quick_log$en._(_root);
	@override late final _Translations$tasks_list$en tasks_list = _Translations$tasks_list$en._(_root);
	@override late final _Translations$task_form$en task_form = _Translations$task_form$en._(_root);
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
	@override String get today => 'Today';
	@override String get today_lower => 'today';
	@override String get yesterday => 'yesterday';
}

// Path: journal
class _Translations$journal$en extends Translations$journal$sl {
	_Translations$journal$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Journal';
	@override String get subtitle => 'garden journal';
	@override String get filter_all => 'All';
	@override String get filter_tasks => '✓ Tasks';
	@override String get filter_notes => '✍️ Notes';
	@override String get empty => 'No journal entries yet.';
	@override String get empty_tasks => 'No completed tasks.';
	@override String get empty_notes => 'No notes yet.';
	@override String get timeline => 'Timeline';
	@override String get month_view => 'Month';
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

// Path: tasks_list
class _Translations$tasks_list$en extends Translations$tasks_list$sl {
	_Translations$tasks_list$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tasks';
	@override String get subtitle => 'upcoming and overdue';
	@override String get section_overdue => 'Overdue';
	@override String get section_today => 'Today';
	@override String get section_tomorrow => 'Tomorrow';
	@override String get section_this_week => 'This week';
	@override String get section_later => 'Later';
	@override String get empty => 'No pending tasks. Add one with +.';
	@override String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'overdue 1 day',
		other: 'overdue {n} days',
	);
	@override String get status_today => 'today';
	@override String get status_tomorrow => 'tomorrow';
	@override String get action_complete => 'Complete';
	@override String get action_postpone => '+1 day';
	@override String get action_edit => 'Edit';
	@override String get action_duplicate => 'Duplicate';
	@override String get action_delete => 'Delete';
	@override String get delete_confirm_title => 'Delete task?';
	@override String get delete_confirm_body => 'This action cannot be undone.';
	@override String get delete_yes => 'Delete';
	@override String get delete_cancel => 'Cancel';
}

// Path: task_form
class _Translations$task_form$en extends Translations$task_form$sl {
	_Translations$task_form$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'New task';
	@override String get title_edit => 'Edit task';
	@override String get what => 'What';
	@override String get what_hint => 'Select task type';
	@override String get when => 'When';
	@override String get status => 'Status';
	@override String get status_waiting => 'Waiting';
	@override String get status_done => 'Done';
	@override String get area => 'Area';
	@override String get no_areas => 'No areas yet — add them in the Areas section.';
	@override String get plant => 'Plant';
	@override String get plant_hint => '(for pruning, treatment, harvesting…)';
	@override String get plant_add => '+ Select plant';
	@override String get plant_note => 'Link to a plant, not just an area.';
	@override String get supplies => 'Supplies used';
	@override String get supplies_add => '+ Add supply';
	@override String get reminders => 'Reminder (optional)';
	@override String get reminders_add => '+ Add reminder';
	@override String get recurrence => 'Recurrence';
	@override String get recurrence_once => 'Once';
	@override String get recurrence_weekly => 'Weekly';
	@override String get recurrence_seasonal => 'Seasonal';
	@override String get note => 'Note (optional)';
	@override String get note_hint => 'Morning, before expected rain.';
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
			'common.today' => 'Today',
			'common.today_lower' => 'today',
			'common.yesterday' => 'yesterday',
			'journal.title' => 'Journal',
			'journal.subtitle' => 'garden journal',
			'journal.filter_all' => 'All',
			'journal.filter_tasks' => '✓ Tasks',
			'journal.filter_notes' => '✍️ Notes',
			'journal.empty' => 'No journal entries yet.',
			'journal.empty_tasks' => 'No completed tasks.',
			'journal.empty_notes' => 'No notes yet.',
			'journal.timeline' => 'Timeline',
			'journal.month_view' => 'Month',
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
			'tasks_list.title' => 'Tasks',
			'tasks_list.subtitle' => 'upcoming and overdue',
			'tasks_list.section_overdue' => 'Overdue',
			'tasks_list.section_today' => 'Today',
			'tasks_list.section_tomorrow' => 'Tomorrow',
			'tasks_list.section_this_week' => 'This week',
			'tasks_list.section_later' => 'Later',
			'tasks_list.empty' => 'No pending tasks. Add one with +.',
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'overdue 1 day', other: 'overdue {n} days', ), 
			'tasks_list.status_today' => 'today',
			'tasks_list.status_tomorrow' => 'tomorrow',
			'tasks_list.action_complete' => 'Complete',
			'tasks_list.action_postpone' => '+1 day',
			'tasks_list.action_edit' => 'Edit',
			'tasks_list.action_duplicate' => 'Duplicate',
			'tasks_list.action_delete' => 'Delete',
			'tasks_list.delete_confirm_title' => 'Delete task?',
			'tasks_list.delete_confirm_body' => 'This action cannot be undone.',
			'tasks_list.delete_yes' => 'Delete',
			'tasks_list.delete_cancel' => 'Cancel',
			'task_form.title_new' => 'New task',
			'task_form.title_edit' => 'Edit task',
			'task_form.what' => 'What',
			'task_form.what_hint' => 'Select task type',
			'task_form.when' => 'When',
			'task_form.status' => 'Status',
			'task_form.status_waiting' => 'Waiting',
			'task_form.status_done' => 'Done',
			'task_form.area' => 'Area',
			'task_form.no_areas' => 'No areas yet — add them in the Areas section.',
			'task_form.plant' => 'Plant',
			'task_form.plant_hint' => '(for pruning, treatment, harvesting…)',
			'task_form.plant_add' => '+ Select plant',
			'task_form.plant_note' => 'Link to a plant, not just an area.',
			'task_form.supplies' => 'Supplies used',
			'task_form.supplies_add' => '+ Add supply',
			'task_form.reminders' => 'Reminder (optional)',
			'task_form.reminders_add' => '+ Add reminder',
			'task_form.recurrence' => 'Recurrence',
			'task_form.recurrence_once' => 'Once',
			'task_form.recurrence_weekly' => 'Weekly',
			'task_form.recurrence_seasonal' => 'Seasonal',
			'task_form.note' => 'Note (optional)',
			'task_form.note_hint' => 'Morning, before expected rain.',
			'task_form.save' => 'Save task',
			'task_form.err_type' => 'Select a task type.',
			'task_form.err_area' => 'Select an area.',
			_ => null,
		};
	}
}

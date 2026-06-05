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
	@override late final _Translations$onboarding$en onboarding = _Translations$onboarding$en._(_root);
	@override late final _Translations$auth$en auth = _Translations$auth$en._(_root);
	@override late final _Translations$email_login$en email_login = _Translations$email_login$en._(_root);
	@override late final _Translations$location$en location = _Translations$location$en._(_root);
	@override late final _Translations$journal$en journal = _Translations$journal$en._(_root);
	@override late final _Translations$notes$en notes = _Translations$notes$en._(_root);
	@override late final _Translations$task_detail$en task_detail = _Translations$task_detail$en._(_root);
	@override late final _Translations$tasks_list$en tasks_list = _Translations$tasks_list$en._(_root);
	@override late final _Translations$subject_picker$en subject_picker = _Translations$subject_picker$en._(_root);
	@override late final _Translations$entry$en entry = _Translations$entry$en._(_root);
	@override late final _Translations$plant_edit$en plant_edit = _Translations$plant_edit$en._(_root);
	@override late final _Translations$plant_detail$en plant_detail = _Translations$plant_detail$en._(_root);
	@override late final _Translations$areas$en areas = _Translations$areas$en._(_root);
	@override late final _Translations$plants$en plants = _Translations$plants$en._(_root);
	@override late final _Translations$supplies$en supplies = _Translations$supplies$en._(_root);
	@override late final _Translations$settings$en settings = _Translations$settings$en._(_root);
	@override late final _Translations$weather$en weather = _Translations$weather$en._(_root);
}

// Path: nav
class _Translations$nav$en extends Translations$nav$sl {
	_Translations$nav$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Home';
	@override String get journal => 'Journal';
	@override String get areas => 'Garden';
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
}

// Path: common
class _Translations$common$en extends Translations$common$sl {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get today => 'Today';
	@override String get yesterday => 'yesterday';
}

// Path: onboarding
class _Translations$onboarding$en extends Translations$onboarding$sl {
	_Translations$onboarding$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get skip => 'Skip ›';
	@override String get next => 'Next';
	@override String get start => 'Get started 🌿';
	@override String get soon_badge => 'soon (V2)';
	@override String get welcome_title => 'Welcome to Tendask';
	@override String get welcome_body => 'Your simple diary for the garden, lawn and hedge — every task in one place.';
	@override String get log_title => 'Log it in seconds';
	@override String get log_body => 'Mowed, watered, fertilised? Note what, when and where — in a couple of taps. Weather is saved automatically.';
	@override String get remind_title => 'Reminders + weather';
	@override String get remind_body => 'Plan tasks, get a reminder on your phone and a weather hint — "dry tomorrow morning, a good time to spray".';
	@override String get nearby_title => 'Your area';
	@override String get nearby_body => 'Later: see what gardeners in a similar climate near you are doing — anonymous and private.';
}

// Path: auth
class _Translations$auth$en extends Translations$auth$sl {
	_Translations$auth$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Welcome to Tendask';
	@override String get title_link => 'Link your account';
	@override String get value_prop => 'Save your garden journal and don\'t lose your history when you change phones.';
	@override String get continue_apple => 'Continue with Apple';
	@override String get continue_google => 'Continue with Google';
	@override String get continue_email => 'Continue with email';
	@override String get guest => 'Try without an account';
	@override String get legal => 'We\'ll send a confirmation code by email (no password). Continuing means you agree to the terms and privacy policy.';
	@override String get guest_warning => 'Without an account, all your data is lost if you remove the app or change device.';
	@override String get coming_soon => 'Coming soon.';
}

// Path: email_login
class _Translations$email_login$en extends Translations$email_login$sl {
	_Translations$email_login$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sign in with email';
	@override String get email_label => 'Email address';
	@override String get email_hint => 'you@example.com';
	@override String get send_code => 'Send code';
	@override String get intro => 'We\'ll send you a one-time code — no password.';
	@override String get code_label => 'Code from email';
	@override String get code_hint => 'Enter the code you received';
	@override String code_sent({required Object email}) => 'We sent a code to ${email}. Enter it below.';
	@override String get verify => 'Confirm and sign in';
	@override String get resend => 'Send a new code';
	@override String get err_email => 'Enter a valid email address.';
	@override String get err_code => 'Enter the code from the email.';
	@override String get err_send => 'Couldn\'t send the code. Check your connection and try again.';
	@override String get err_verify => 'The code is wrong or has expired. Try again.';
	@override String get switch_warn_title => 'Switch account?';
	@override String get switch_warn_body => 'Signing into this account will remove the data on this device. To keep it, cancel and use "Link account" in Settings.';
	@override String get switch_warn_confirm => 'Switch anyway';
	@override String get switch_warn_cancel => 'Cancel';
}

// Path: location
class _Translations$location$en extends Translations$location$sl {
	_Translations$location$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Where do you garden?';
	@override String get why => 'We need your location for the local weather forecast and (later) to show you what gardeners in a similar climate are doing.';
	@override String get use_gps => 'Use my location';
	@override String get or_enter => 'or enter a place';
	@override String get place_hint => 'Village, town or address (e.g. Šentjur)';
	@override String get place_note => 'A village or town is enough — no exact address needed.';
	@override String get search => 'Search';
	@override String get privacy => 'We use your location only to roughly determine your surroundings (an area of a few kilometres). Your exact location stays on your device — we keep only the rough surroundings and never reveal it to others.';
	@override String get kContinue => 'Continue';
	@override String get detecting => 'Detecting location…';
	@override String get set_gps => 'Location set.';
	@override String set_place({required Object name}) => 'Location: ${name}';
	@override String get err_denied => 'Location access denied. Enter a place or grant permission in system settings.';
	@override String get err_disabled => 'Location services are off. Turn them on or enter a place.';
	@override String get err_unavailable => 'Couldn\'t determine your location. Try again or enter a place.';
	@override String get err_search => 'Search failed. Check your connection and try again.';
	@override String get no_results => 'No matches for that place.';
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
	@override String get month_hint => '💡 Tap a day to view and add tasks.';
	@override String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} task this month',
		other: '${n} tasks this month',
	);
	@override String get day_empty => 'No tasks on this day.';
	@override String get day_add => 'Add task on this day';
}

// Path: notes
class _Translations$notes$en extends Translations$notes$sl {
	_Translations$notes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'New note';
	@override String get title_edit => 'Edit note';
	@override String get content_label => 'Note';
	@override String get content_hint => 'Free text — observation, idea, thought…';
	@override String get when => 'When';
	@override String get today => 'Today';
	@override String get yesterday => 'Yesterday';
	@override String get pick_date => 'Date…';
	@override String get area => 'Area (optional)';
	@override String get no_areas => 'No areas yet — add them in the Areas section.';
	@override String get plant => 'Plant (optional)';
	@override String get save => 'Save note';
	@override String get err_content => 'Enter the note text.';
	@override String get delete => 'Delete note';
	@override String get delete_confirm => 'This action cannot be undone.';
	@override String get info => '🌧️ Weather is saved automatically.';
}

// Path: task_detail
class _Translations$task_detail$en extends Translations$task_detail$sl {
	_Translations$task_detail$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get section_weather => 'Weather snapshot';
	@override String get section_details => 'Details';
	@override String get label_supplies => 'Supplies';
	@override String get label_reminder => 'Reminder';
	@override String get label_recurrence => 'Recurrence';
	@override String get label_note => 'Note';
	@override String get badge_waiting => 'Planned';
	@override String get badge_done => 'Done';
	@override String get action_complete => '✓  Mark as done';
	@override String get action_postpone => '+1 day';
	@override String get action_edit => 'Edit';
	@override String get action_duplicate => 'Duplicate';
	@override String get action_delete => 'Delete';
	@override String get action_revert => 'Back to waiting';
	@override String get action_move => 'Reschedule';
	@override String get recurrence_once => 'Once';
	@override String get recurrence_weekly => 'Weekly';
	@override String get recurrence_seasonal => 'Seasonal';
	@override String get none => '—';
	@override String get not_found => 'Task not found.';
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
		other: 'overdue ${n} days',
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

// Path: subject_picker
class _Translations$subject_picker$en extends Translations$subject_picker$sl {
	_Translations$subject_picker$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Plant or area';
	@override String get choose => 'Choose';
}

// Path: entry
class _Translations$entry$en extends Translations$entry$sl {
	_Translations$entry$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'New task';
	@override String get title_review => 'Review';
	@override String get kContinue => 'Continue';
	@override String get skip => 'Skip';
	@override String get save => 'Save task';
	@override String get step => 'Step';
	@override String get note_card_title => 'Just a note, no task?';
	@override String get note_card_action => 'Note ›';
	@override String get repeat_last => 'Repeat last';
	@override String get type_title => 'Which task?';
	@override String get type_hint => 'Tapping a task takes you forward automatically.';
	@override String type_show_all({required Object n}) => 'Show all (${n})';
	@override String get type_show_less => 'Show less';
	@override String get subject_title => 'For what?';
	@override String get subject_search_hint => 'Search plant…';
	@override String get subject_plants => 'Plants';
	@override String get subject_add_plant => 'Add plant';
	@override String get subject_add_area => 'Add area';
	@override String get subject_from_catalog => 'Add from catalog';
	@override String get subject_areas_context => 'Areas:';
	@override String get subject_area_section => 'Or the whole area';
	@override String get subject_area_note => 'Pick an area only when the task applies to the whole thing without a single plant (mowing, mulching a whole bed).';
	@override String get when_title => 'When';
	@override String get when_today => 'Today';
	@override String get when_tomorrow => 'Tomorrow';
	@override String get when_pick_date => 'Date…';
	@override String get when_date => 'Date';
	@override String get when_time => 'Time';
	@override String get when_default_note => 'Default: today at the next full hour.';
	@override String get when_status => 'Status';
	@override String get when_status_waiting => 'Waiting';
	@override String get when_status_done => 'Done';
	@override String get when_status_note => 'Default derived from the date and time: future = waiting, otherwise = done.';
	@override String get reminder_title => 'Reminder';
	@override String get optional => '(optional)';
	@override String get reminder_why => 'This step is here because the task is planned (Waiting). A reminder notifies you on your phone at the chosen time.';
	@override String get reminder_add => 'Add reminder';
	@override String get reminder_note => 'Adjustable offset and time. Several reminders per task.';
	@override String get supplies_title => 'Supplies';
	@override String get supplies_why => 'This step is here because the task usually consumes supplies. They are deducted from stock.';
	@override String get supplies_add => 'Add supply from stock';
	@override String get supplies_note => 'One mix for all selected plants — deducted once.';
	@override String get review_title => 'Check it over — tap a row to edit';
	@override String get review_type => 'Task';
	@override String get review_subject => 'For what';
	@override String get review_when => 'When';
	@override String get review_reminder => 'Reminder';
	@override String get review_supplies => 'Supplies';
	@override String get review_fix => 'Edit';
	@override String get review_none => '—';
	@override String get note_label => 'Note';
	@override String get note_hint => 'e.g. in the morning before forecast rain';
	@override String get weather_note => '🌧️ Weather is saved automatically on completion.';
	@override String get err_subject => 'Pick at least one plant or area.';
	@override String get rem_event => 'At event time';
	@override String get rem_10min => '10 minutes before';
	@override String get rem_1hour => '1 hour before';
	@override String get rem_1day => '1 day before';
	@override String get rem_2day => '2 days before';
	@override String rem_at({required Object t}) => 'at ${t}';
	@override String get rem_choose_time => 'At time';
	@override String get rem_time_note => 'The time applies to day-based offsets (e.g. "1 day before at 18:00").';
}

// Path: plant_edit
class _Translations$plant_edit$en extends Translations$plant_edit$sl {
	_Translations$plant_edit$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title_new => 'Add plant';
	@override String get title_edit => 'Edit plant';
	@override String get species => 'Species';
	@override String get species_choose => 'Choose species';
	@override String get species_change => 'Change';
	@override String get alias => 'Personal name (optional)';
	@override String get alias_hint => 'e.g. “old apple by the fence”';
	@override String get alias_note => 'Only you see it; shown instead of the default name.';
	@override String get locations => 'Where it grows';
	@override String get locations_hint => 'pick one or more areas';
	@override String get locations_note => 'No area is fine too (e.g. a pot on the terrace).';
	@override String get new_area => 'New area';
	@override String get delete => 'Remove plant from garden';
	@override String get delete_note => 'Task history stays in the journal.';
	@override String get save => 'Save';
	@override String get err_species => 'Choose a species first.';
}

// Path: plant_detail
class _Translations$plant_detail$en extends Translations$plant_detail$sl {
	_Translations$plant_detail$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get not_found => 'Plant not found.';
	@override String get history_title => 'Task history';
	@override String get history_empty => 'No tasks for this plant yet.';
}

// Path: areas
class _Translations$areas$en extends Translations$areas$sl {
	_Translations$areas$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Garden';
	@override String get subtitle => 'plants and lawns';
	@override String get empty => 'No areas yet. Add your first with +.';
	@override String get last_prefix => 'last:';
	@override String get type_lawn => 'Lawn';
	@override String get type_hedge => 'Hedge';
	@override String get type_bed => 'Bed';
	@override String get type_tree => 'Fruit tree';
	@override String get type_ornamental => 'Ornamental';
	@override String get type_other => 'Other';
	@override String get history_title => 'Task history';
	@override String get history_empty => 'No tasks in this area yet.';
	@override String get action_edit => 'Edit';
	@override String get action_delete => 'Delete';
	@override String get delete_confirm_title => 'Delete area?';
	@override String get delete_confirm_body => 'Tasks remain but lose their link to this area.';
	@override String get form_title_new => 'New area';
	@override String get form_title_edit => 'Edit area';
	@override String get form_name => 'Name';
	@override String get form_name_hint => 'e.g. Raised bed 1';
	@override String get form_type => 'Type';
	@override String get form_plants => 'Plants in area';
	@override String get form_plants_add => 'Add plant';
	@override String get form_plants_note => 'Tasks (pruning, treatment, harvesting) link to the selected plant.';
	@override String get form_save => 'Save area';
	@override String get err_name => 'Enter an area name.';
	@override String get plants_empty => 'No plants yet.';
	@override String get plant_remove => 'Remove';
}

// Path: plants
class _Translations$plants$en extends Translations$plants$sl {
	_Translations$plants$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get picker_title => 'Select plant';
	@override String get search_hint => 'Search plant…';
	@override String get cat_all => 'All';
	@override String get cat_fruit_tree => 'Fruit trees';
	@override String get cat_berries => 'Berries';
	@override String get cat_vegetable => 'Vegetables';
	@override String get cat_herbs => 'Herbs';
	@override String get cat_ornamental => 'Ornamental';
	@override String get cat_lawn => 'Lawn';
	@override String get from_catalog => 'From catalog';
	@override String get not_found => 'Can\'t find it?';
	@override String custom_add({required Object q}) => '+ Add custom: “${q}”';
	@override String get custom_private => 'A custom entry is private and not shared with the community.';
	@override String get field_add => 'Select plant';
	@override String get field_empty => 'This area has no plants yet. Add one with the button below.';
}

// Path: supplies
class _Translations$supplies$en extends Translations$supplies$sl {
	_Translations$supplies$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Supplies';
	@override String get subtitle => 'what I have at home';
	@override String get empty => 'No supplies yet. Add some with +.';
	@override String get low => 'low';
	@override String qty({required Object q, required Object unit}) => '~${q}${unit}';
	@override String get form_new => 'New supply';
	@override String get form_edit => 'Edit supply';
	@override String get form_name => 'Name';
	@override String get form_quantity => 'Quantity';
	@override String get form_unit => 'Unit';
	@override String get form_threshold => 'Warn at (threshold)';
	@override String get form_save => 'Save';
	@override String get err_name => 'Enter a supply name.';
	@override String get add_to_task => 'Add supply';
	@override String get pick_new => 'New supply';
	@override String get amount => 'Amount used';
	@override String get add_confirm => 'Add';
}

// Path: settings
class _Translations$settings$en extends Translations$settings$sl {
	_Translations$settings$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get profile_guest => 'Guest (not signed in)';
	@override String get sign_in_prompt => 'Sign in to back up your data';
	@override String get signed_in => 'Signed in — data backed up';
	@override String get section_location => 'Location';
	@override String get location_placeholder => 'Weather location';
	@override String get section_language => 'Language';
	@override String get section_notifications => 'Notifications';
	@override String get notifications_placeholder => 'Notifications and reminders';
	@override String get section_garden => 'Garden';
	@override String get supplies => '📦 Supplies';
	@override String get supplies_sub => 'urea, algae, fertilizers, gear';
	@override String get areas => '🪴 Areas';
	@override String get areas_sub => 'lawns, hedges, beds';
	@override String get section_account => 'Account & data';
	@override String get units => 'Units';
	@override String get export_data => 'Export data (GDPR)';
	@override String get logout => 'Sign out';
	@override String get logout_confirm_title => 'Sign out?';
	@override String get logout_confirm_body => 'Signs you out and clears local data from this device. Synced data stays in the cloud and returns when you sign in again with the same account.';
	@override String get logout_cancel => 'Cancel';
	@override String get logout_offline => 'Can\'t sign out while offline — your data isn\'t saved to the cloud yet. Try again when you\'re connected.';
	@override String get delete_account => 'Delete account and all data';
	@override String get coming_soon => 'Coming soon';
	@override String get version => 'Tendask · v1 (MVP)';
}

// Path: weather
class _Translations$weather$en extends Translations$weather$sl {
	_Translations$weather$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cond_clear => 'Clear';
	@override String get cond_mainly_clear => 'Mostly clear';
	@override String get cond_cloudy => 'Cloudy';
	@override String get cond_fog => 'Fog';
	@override String get cond_drizzle => 'Drizzle';
	@override String get cond_rain => 'Rain';
	@override String get cond_snow => 'Snow';
	@override String get cond_showers => 'Showers';
	@override String get cond_thunderstorm => 'Thunderstorm';
	@override String get cond_unknown => '—';
	@override String get band_forecast => 'Forecast';
	@override String get rain_past48h => 'Rain last 48 h:';
	@override String get detail_waiting => 'Weather will be recorded when you mark the task done.';
	@override String get detail_none => 'No weather snapshot (captured offline).';
	@override String get home_unavailable => 'Weather is currently unavailable.';
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
			'nav.areas' => 'Garden',
			'nav.tasks' => 'Tasks',
			'home.greeting' => 'Good day 🌿',
			'home.today' => 'Today',
			'home.recent' => 'Recent',
			'home.no_tasks_today' => 'No tasks planned for today.',
			'home.no_recent' => 'No completed tasks yet.',
			'common.today' => 'Today',
			'common.yesterday' => 'yesterday',
			'onboarding.skip' => 'Skip ›',
			'onboarding.next' => 'Next',
			'onboarding.start' => 'Get started 🌿',
			'onboarding.soon_badge' => 'soon (V2)',
			'onboarding.welcome_title' => 'Welcome to Tendask',
			'onboarding.welcome_body' => 'Your simple diary for the garden, lawn and hedge — every task in one place.',
			'onboarding.log_title' => 'Log it in seconds',
			'onboarding.log_body' => 'Mowed, watered, fertilised? Note what, when and where — in a couple of taps. Weather is saved automatically.',
			'onboarding.remind_title' => 'Reminders + weather',
			'onboarding.remind_body' => 'Plan tasks, get a reminder on your phone and a weather hint — "dry tomorrow morning, a good time to spray".',
			'onboarding.nearby_title' => 'Your area',
			'onboarding.nearby_body' => 'Later: see what gardeners in a similar climate near you are doing — anonymous and private.',
			'auth.title' => 'Welcome to Tendask',
			'auth.title_link' => 'Link your account',
			'auth.value_prop' => 'Save your garden journal and don\'t lose your history when you change phones.',
			'auth.continue_apple' => 'Continue with Apple',
			'auth.continue_google' => 'Continue with Google',
			'auth.continue_email' => 'Continue with email',
			'auth.guest' => 'Try without an account',
			'auth.legal' => 'We\'ll send a confirmation code by email (no password). Continuing means you agree to the terms and privacy policy.',
			'auth.guest_warning' => 'Without an account, all your data is lost if you remove the app or change device.',
			'auth.coming_soon' => 'Coming soon.',
			'email_login.title' => 'Sign in with email',
			'email_login.email_label' => 'Email address',
			'email_login.email_hint' => 'you@example.com',
			'email_login.send_code' => 'Send code',
			'email_login.intro' => 'We\'ll send you a one-time code — no password.',
			'email_login.code_label' => 'Code from email',
			'email_login.code_hint' => 'Enter the code you received',
			'email_login.code_sent' => ({required Object email}) => 'We sent a code to ${email}. Enter it below.',
			'email_login.verify' => 'Confirm and sign in',
			'email_login.resend' => 'Send a new code',
			'email_login.err_email' => 'Enter a valid email address.',
			'email_login.err_code' => 'Enter the code from the email.',
			'email_login.err_send' => 'Couldn\'t send the code. Check your connection and try again.',
			'email_login.err_verify' => 'The code is wrong or has expired. Try again.',
			'email_login.switch_warn_title' => 'Switch account?',
			'email_login.switch_warn_body' => 'Signing into this account will remove the data on this device. To keep it, cancel and use "Link account" in Settings.',
			'email_login.switch_warn_confirm' => 'Switch anyway',
			'email_login.switch_warn_cancel' => 'Cancel',
			'location.title' => 'Where do you garden?',
			'location.why' => 'We need your location for the local weather forecast and (later) to show you what gardeners in a similar climate are doing.',
			'location.use_gps' => 'Use my location',
			'location.or_enter' => 'or enter a place',
			'location.place_hint' => 'Village, town or address (e.g. Šentjur)',
			'location.place_note' => 'A village or town is enough — no exact address needed.',
			'location.search' => 'Search',
			'location.privacy' => 'We use your location only to roughly determine your surroundings (an area of a few kilometres). Your exact location stays on your device — we keep only the rough surroundings and never reveal it to others.',
			'location.kContinue' => 'Continue',
			'location.detecting' => 'Detecting location…',
			'location.set_gps' => 'Location set.',
			'location.set_place' => ({required Object name}) => 'Location: ${name}',
			'location.err_denied' => 'Location access denied. Enter a place or grant permission in system settings.',
			'location.err_disabled' => 'Location services are off. Turn them on or enter a place.',
			'location.err_unavailable' => 'Couldn\'t determine your location. Try again or enter a place.',
			'location.err_search' => 'Search failed. Check your connection and try again.',
			'location.no_results' => 'No matches for that place.',
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
			'journal.month_hint' => '💡 Tap a day to view and add tasks.',
			'journal.month_count' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} task this month', other: '${n} tasks this month', ), 
			'journal.day_empty' => 'No tasks on this day.',
			'journal.day_add' => 'Add task on this day',
			'notes.title_new' => 'New note',
			'notes.title_edit' => 'Edit note',
			'notes.content_label' => 'Note',
			'notes.content_hint' => 'Free text — observation, idea, thought…',
			'notes.when' => 'When',
			'notes.today' => 'Today',
			'notes.yesterday' => 'Yesterday',
			'notes.pick_date' => 'Date…',
			'notes.area' => 'Area (optional)',
			'notes.no_areas' => 'No areas yet — add them in the Areas section.',
			'notes.plant' => 'Plant (optional)',
			'notes.save' => 'Save note',
			'notes.err_content' => 'Enter the note text.',
			'notes.delete' => 'Delete note',
			'notes.delete_confirm' => 'This action cannot be undone.',
			'notes.info' => '🌧️ Weather is saved automatically.',
			'task_detail.section_weather' => 'Weather snapshot',
			'task_detail.section_details' => 'Details',
			'task_detail.label_supplies' => 'Supplies',
			'task_detail.label_reminder' => 'Reminder',
			'task_detail.label_recurrence' => 'Recurrence',
			'task_detail.label_note' => 'Note',
			'task_detail.badge_waiting' => 'Planned',
			'task_detail.badge_done' => 'Done',
			'task_detail.action_complete' => '✓  Mark as done',
			'task_detail.action_postpone' => '+1 day',
			'task_detail.action_edit' => 'Edit',
			'task_detail.action_duplicate' => 'Duplicate',
			'task_detail.action_delete' => 'Delete',
			'task_detail.action_revert' => 'Back to waiting',
			'task_detail.action_move' => 'Reschedule',
			'task_detail.recurrence_once' => 'Once',
			'task_detail.recurrence_weekly' => 'Weekly',
			'task_detail.recurrence_seasonal' => 'Seasonal',
			'task_detail.none' => '—',
			'task_detail.not_found' => 'Task not found.',
			'tasks_list.title' => 'Tasks',
			'tasks_list.subtitle' => 'upcoming and overdue',
			'tasks_list.section_overdue' => 'Overdue',
			'tasks_list.section_today' => 'Today',
			'tasks_list.section_tomorrow' => 'Tomorrow',
			'tasks_list.section_this_week' => 'This week',
			'tasks_list.section_later' => 'Later',
			'tasks_list.empty' => 'No pending tasks. Add one with +.',
			'tasks_list.overdue_days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'overdue 1 day', other: 'overdue ${n} days', ), 
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
			'subject_picker.title' => 'Plant or area',
			'subject_picker.choose' => 'Choose',
			'entry.title_new' => 'New task',
			'entry.title_review' => 'Review',
			'entry.kContinue' => 'Continue',
			'entry.skip' => 'Skip',
			'entry.save' => 'Save task',
			'entry.step' => 'Step',
			'entry.note_card_title' => 'Just a note, no task?',
			'entry.note_card_action' => 'Note ›',
			'entry.repeat_last' => 'Repeat last',
			'entry.type_title' => 'Which task?',
			'entry.type_hint' => 'Tapping a task takes you forward automatically.',
			'entry.type_show_all' => ({required Object n}) => 'Show all (${n})',
			'entry.type_show_less' => 'Show less',
			'entry.subject_title' => 'For what?',
			'entry.subject_search_hint' => 'Search plant…',
			'entry.subject_plants' => 'Plants',
			'entry.subject_add_plant' => 'Add plant',
			'entry.subject_add_area' => 'Add area',
			'entry.subject_from_catalog' => 'Add from catalog',
			'entry.subject_areas_context' => 'Areas:',
			'entry.subject_area_section' => 'Or the whole area',
			'entry.subject_area_note' => 'Pick an area only when the task applies to the whole thing without a single plant (mowing, mulching a whole bed).',
			'entry.when_title' => 'When',
			'entry.when_today' => 'Today',
			'entry.when_tomorrow' => 'Tomorrow',
			'entry.when_pick_date' => 'Date…',
			'entry.when_date' => 'Date',
			'entry.when_time' => 'Time',
			'entry.when_default_note' => 'Default: today at the next full hour.',
			'entry.when_status' => 'Status',
			'entry.when_status_waiting' => 'Waiting',
			'entry.when_status_done' => 'Done',
			'entry.when_status_note' => 'Default derived from the date and time: future = waiting, otherwise = done.',
			'entry.reminder_title' => 'Reminder',
			'entry.optional' => '(optional)',
			'entry.reminder_why' => 'This step is here because the task is planned (Waiting). A reminder notifies you on your phone at the chosen time.',
			'entry.reminder_add' => 'Add reminder',
			'entry.reminder_note' => 'Adjustable offset and time. Several reminders per task.',
			'entry.supplies_title' => 'Supplies',
			'entry.supplies_why' => 'This step is here because the task usually consumes supplies. They are deducted from stock.',
			'entry.supplies_add' => 'Add supply from stock',
			'entry.supplies_note' => 'One mix for all selected plants — deducted once.',
			'entry.review_title' => 'Check it over — tap a row to edit',
			'entry.review_type' => 'Task',
			'entry.review_subject' => 'For what',
			'entry.review_when' => 'When',
			'entry.review_reminder' => 'Reminder',
			'entry.review_supplies' => 'Supplies',
			'entry.review_fix' => 'Edit',
			'entry.review_none' => '—',
			'entry.note_label' => 'Note',
			'entry.note_hint' => 'e.g. in the morning before forecast rain',
			'entry.weather_note' => '🌧️ Weather is saved automatically on completion.',
			'entry.err_subject' => 'Pick at least one plant or area.',
			'entry.rem_event' => 'At event time',
			'entry.rem_10min' => '10 minutes before',
			'entry.rem_1hour' => '1 hour before',
			'entry.rem_1day' => '1 day before',
			'entry.rem_2day' => '2 days before',
			'entry.rem_at' => ({required Object t}) => 'at ${t}',
			'entry.rem_choose_time' => 'At time',
			'entry.rem_time_note' => 'The time applies to day-based offsets (e.g. "1 day before at 18:00").',
			'plant_edit.title_new' => 'Add plant',
			'plant_edit.title_edit' => 'Edit plant',
			'plant_edit.species' => 'Species',
			'plant_edit.species_choose' => 'Choose species',
			'plant_edit.species_change' => 'Change',
			'plant_edit.alias' => 'Personal name (optional)',
			'plant_edit.alias_hint' => 'e.g. “old apple by the fence”',
			'plant_edit.alias_note' => 'Only you see it; shown instead of the default name.',
			'plant_edit.locations' => 'Where it grows',
			'plant_edit.locations_hint' => 'pick one or more areas',
			'plant_edit.locations_note' => 'No area is fine too (e.g. a pot on the terrace).',
			'plant_edit.new_area' => 'New area',
			'plant_edit.delete' => 'Remove plant from garden',
			'plant_edit.delete_note' => 'Task history stays in the journal.',
			'plant_edit.save' => 'Save',
			'plant_edit.err_species' => 'Choose a species first.',
			'plant_detail.not_found' => 'Plant not found.',
			'plant_detail.history_title' => 'Task history',
			'plant_detail.history_empty' => 'No tasks for this plant yet.',
			'areas.title' => 'Garden',
			'areas.subtitle' => 'plants and lawns',
			'areas.empty' => 'No areas yet. Add your first with +.',
			'areas.last_prefix' => 'last:',
			'areas.type_lawn' => 'Lawn',
			'areas.type_hedge' => 'Hedge',
			'areas.type_bed' => 'Bed',
			'areas.type_tree' => 'Fruit tree',
			'areas.type_ornamental' => 'Ornamental',
			'areas.type_other' => 'Other',
			'areas.history_title' => 'Task history',
			'areas.history_empty' => 'No tasks in this area yet.',
			'areas.action_edit' => 'Edit',
			'areas.action_delete' => 'Delete',
			'areas.delete_confirm_title' => 'Delete area?',
			'areas.delete_confirm_body' => 'Tasks remain but lose their link to this area.',
			'areas.form_title_new' => 'New area',
			'areas.form_title_edit' => 'Edit area',
			'areas.form_name' => 'Name',
			'areas.form_name_hint' => 'e.g. Raised bed 1',
			'areas.form_type' => 'Type',
			'areas.form_plants' => 'Plants in area',
			'areas.form_plants_add' => 'Add plant',
			'areas.form_plants_note' => 'Tasks (pruning, treatment, harvesting) link to the selected plant.',
			'areas.form_save' => 'Save area',
			'areas.err_name' => 'Enter an area name.',
			'areas.plants_empty' => 'No plants yet.',
			'areas.plant_remove' => 'Remove',
			'plants.picker_title' => 'Select plant',
			'plants.search_hint' => 'Search plant…',
			'plants.cat_all' => 'All',
			'plants.cat_fruit_tree' => 'Fruit trees',
			'plants.cat_berries' => 'Berries',
			'plants.cat_vegetable' => 'Vegetables',
			'plants.cat_herbs' => 'Herbs',
			'plants.cat_ornamental' => 'Ornamental',
			'plants.cat_lawn' => 'Lawn',
			'plants.from_catalog' => 'From catalog',
			'plants.not_found' => 'Can\'t find it?',
			'plants.custom_add' => ({required Object q}) => '+ Add custom: “${q}”',
			'plants.custom_private' => 'A custom entry is private and not shared with the community.',
			'plants.field_add' => 'Select plant',
			'plants.field_empty' => 'This area has no plants yet. Add one with the button below.',
			'supplies.title' => 'Supplies',
			'supplies.subtitle' => 'what I have at home',
			'supplies.empty' => 'No supplies yet. Add some with +.',
			'supplies.low' => 'low',
			'supplies.qty' => ({required Object q, required Object unit}) => '~${q}${unit}',
			'supplies.form_new' => 'New supply',
			'supplies.form_edit' => 'Edit supply',
			'supplies.form_name' => 'Name',
			'supplies.form_quantity' => 'Quantity',
			'supplies.form_unit' => 'Unit',
			'supplies.form_threshold' => 'Warn at (threshold)',
			'supplies.form_save' => 'Save',
			'supplies.err_name' => 'Enter a supply name.',
			'supplies.add_to_task' => 'Add supply',
			'supplies.pick_new' => 'New supply',
			'supplies.amount' => 'Amount used',
			'supplies.add_confirm' => 'Add',
			'settings.title' => 'Settings',
			'settings.profile_guest' => 'Guest (not signed in)',
			'settings.sign_in_prompt' => 'Sign in to back up your data',
			'settings.signed_in' => 'Signed in — data backed up',
			'settings.section_location' => 'Location',
			'settings.location_placeholder' => 'Weather location',
			'settings.section_language' => 'Language',
			'settings.section_notifications' => 'Notifications',
			'settings.notifications_placeholder' => 'Notifications and reminders',
			'settings.section_garden' => 'Garden',
			'settings.supplies' => '📦 Supplies',
			'settings.supplies_sub' => 'urea, algae, fertilizers, gear',
			'settings.areas' => '🪴 Areas',
			'settings.areas_sub' => 'lawns, hedges, beds',
			'settings.section_account' => 'Account & data',
			'settings.units' => 'Units',
			'settings.export_data' => 'Export data (GDPR)',
			'settings.logout' => 'Sign out',
			'settings.logout_confirm_title' => 'Sign out?',
			'settings.logout_confirm_body' => 'Signs you out and clears local data from this device. Synced data stays in the cloud and returns when you sign in again with the same account.',
			'settings.logout_cancel' => 'Cancel',
			'settings.logout_offline' => 'Can\'t sign out while offline — your data isn\'t saved to the cloud yet. Try again when you\'re connected.',
			'settings.delete_account' => 'Delete account and all data',
			'settings.coming_soon' => 'Coming soon',
			'settings.version' => 'Tendask · v1 (MVP)',
			'weather.cond_clear' => 'Clear',
			'weather.cond_mainly_clear' => 'Mostly clear',
			'weather.cond_cloudy' => 'Cloudy',
			'weather.cond_fog' => 'Fog',
			'weather.cond_drizzle' => 'Drizzle',
			'weather.cond_rain' => 'Rain',
			'weather.cond_snow' => 'Snow',
			'weather.cond_showers' => 'Showers',
			'weather.cond_thunderstorm' => 'Thunderstorm',
			'weather.cond_unknown' => '—',
			'weather.band_forecast' => 'Forecast',
			'weather.rain_past48h' => 'Rain last 48 h:',
			'weather.detail_waiting' => 'Weather will be recorded when you mark the task done.',
			'weather.detail_none' => 'No weather snapshot (captured offline).',
			'weather.home_unavailable' => 'Weather is currently unavailable.',
			_ => null,
		};
	}
}

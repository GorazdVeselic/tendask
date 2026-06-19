///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
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
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$splash$en splash = Translations$splash$en.internal(_root);
	late final Translations$nav$en nav = Translations$nav$en.internal(_root);
	late final Translations$home$en home = Translations$home$en.internal(_root);
	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$swipe$en swipe = Translations$swipe$en.internal(_root);
	late final Translations$notifications$en notifications = Translations$notifications$en.internal(_root);
	late final Translations$notif_priming$en notif_priming = Translations$notif_priming$en.internal(_root);
	late final Translations$notif_settings$en notif_settings = Translations$notif_settings$en.internal(_root);
	late final Translations$notif_preview$en notif_preview = Translations$notif_preview$en.internal(_root);
	late final Translations$onboarding$en onboarding = Translations$onboarding$en.internal(_root);
	late final Translations$auth$en auth = Translations$auth$en.internal(_root);
	late final Translations$email_login$en email_login = Translations$email_login$en.internal(_root);
	late final Translations$location$en location = Translations$location$en.internal(_root);
	late final Translations$journal$en journal = Translations$journal$en.internal(_root);
	late final Translations$notes$en notes = Translations$notes$en.internal(_root);
	late final Translations$task_detail$en task_detail = Translations$task_detail$en.internal(_root);
	late final Translations$tasks_list$en tasks_list = Translations$tasks_list$en.internal(_root);
	late final Translations$subject_picker$en subject_picker = Translations$subject_picker$en.internal(_root);
	late final Translations$entry$en entry = Translations$entry$en.internal(_root);
	late final Translations$plant_edit$en plant_edit = Translations$plant_edit$en.internal(_root);
	late final Translations$plant_detail$en plant_detail = Translations$plant_detail$en.internal(_root);
	late final Translations$area_pick$en area_pick = Translations$area_pick$en.internal(_root);
	late final Translations$areas$en areas = Translations$areas$en.internal(_root);
	late final Translations$plants$en plants = Translations$plants$en.internal(_root);
	late final Translations$supplies$en supplies = Translations$supplies$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$weather$en weather = Translations$weather$en.internal(_root);
	late final Translations$suggestions$en suggestions = Translations$suggestions$en.internal(_root);
}

// Path: splash
class Translations$splash$en {
	Translations$splash$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your garden journal 🌿'
	String get tagline => 'Your garden journal 🌿';
}

// Path: nav
class Translations$nav$en {
	Translations$nav$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Journal'
	String get journal => 'Journal';

	/// en: 'Garden'
	String get areas => 'Garden';

	/// en: 'Tasks'
	String get tasks => 'Tasks';
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good day 🌿'
	String get greeting => 'Good day 🌿';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Recent'
	String get recent => 'Recent';

	/// en: 'No tasks planned for today.'
	String get no_tasks_today => 'No tasks planned for today.';

	/// en: 'No completed tasks yet.'
	String get no_recent => 'No completed tasks yet.';

	/// en: '(one) {1 overdue task} (other) {$n overdue tasks}'
	String overdue_banner({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 overdue task',
		other: '${n} overdue tasks',
	);
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'yesterday'
	String get yesterday => 'yesterday';

	/// en: 'Couldn't load data.'
	String get load_error => 'Couldn\'t load data.';
}

// Path: swipe
class Translations$swipe$en {
	Translations$swipe$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Done'
	String get complete => 'Done';

	/// en: '+1 day'
	String get postpone => '+1 day';

	/// en: 'Reopen'
	String get revert => 'Reopen';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Move'
	String get move => 'Move';

	/// en: 'Delete'
	String get delete => 'Delete';
}

// Path: notifications
class Translations$notifications$en {
	Translations$notifications$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Tomorrow'
	String get tomorrow => 'Tomorrow';
}

// Path: notif_priming
class Translations$notif_priming$en {
	Translations$notif_priming$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Let me remind you in time?'
	String get title => 'Let me remind you in time?';

	/// en: 'So a task doesn't slip by — the reminder arrives exactly when you set it.'
	String get why => 'So a task doesn\'t slip by — the reminder arrives exactly when you set it.';

	/// en: 'Task reminders — e.g. "1 day before at 18:00".'
	String get benefit_reminders => 'Task reminders — e.g. "1 day before at 18:00".';

	/// en: 'Smart weather hint — "dry tomorrow, a good time". (optional)'
	String get benefit_weather => 'Smart weather hint — "dry tomorrow, a good time". (optional)';

	/// en: 'Neighbourhood hints — what others nearby are doing. (V2, optional)'
	String get benefit_nearby => 'Neighbourhood hints — what others nearby are doing. (V2, optional)';

	/// en: 'You can turn each type on or off separately, set quiet hours and cap frequency. No spam.'
	String get privacy => 'You can turn each type on or off separately, set quiet hours and cap frequency. No spam.';

	/// en: 'Turn on notifications'
	String get enable => 'Turn on notifications';

	/// en: 'Maybe later'
	String get later => 'Maybe later';
}

// Path: notif_settings
class Translations$notif_settings$en {
	Translations$notif_settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'Couldn't load settings.'
	String get load_error => 'Couldn\'t load settings.';

	/// en: 'Notification types'
	String get section_types => 'Notification types';

	/// en: 'Task reminders'
	String get type_reminders => 'Task reminders';

	/// en: 'local · works offline'
	String get type_reminders_sub => 'local · works offline';

	/// en: 'Smart hints (weather)'
	String get type_weather => 'Smart hints (weather)';

	/// en: '"dry tomorrow — a good time"'
	String get type_weather_sub => '"dry tomorrow — a good time"';

	/// en: 'Nearby hints'
	String get type_community => 'Nearby hints';

	/// en: 'what others nearby are doing'
	String get type_community_sub => 'what others nearby are doing';

	/// en: 'Default reminder offset'
	String get section_default_offset => 'Default reminder offset';

	/// en: 'Prefills new tasks; you can always change it.'
	String get default_offset_hint => 'Prefills new tasks; you can always change it.';

	/// en: 'So you're not overwhelmed'
	String get section_quiet => 'So you\'re not overwhelmed';

	/// en: 'Quiet hours'
	String get quiet_hours => 'Quiet hours';

	/// en: '$range, no notifications'
	String quiet_hours_sub({required Object range}) => '${range}, no notifications';

	/// en: 'At most 1 hint per day'
	String get frequency_cap => 'At most 1 hint per day';

	/// en: 'weather and nearby combined into one summary'
	String get frequency_cap_sub => 'weather and nearby combined into one summary';

	/// en: 'More'
	String get section_more => 'More';

	/// en: 'Notification preview'
	String get preview => 'Notification preview';

	/// en: 'how they look on the lock screen'
	String get preview_sub => 'how they look on the lock screen';

	/// en: 'System permission'
	String get system_permission => 'System permission';

	/// en: 'device: allowed'
	String get system_permission_on => 'device: allowed';

	/// en: 'exact reminders not allowed — tap for settings'
	String get system_permission_off => 'exact reminders not allowed — tap for settings';

	/// en: 'Notifications are disabled, so hints can't be turned on.'
	String get hints_perm_denied => 'Notifications are disabled, so hints can\'t be turned on.';
}

// Path: notif_preview
class Translations$notif_preview$en {
	Translations$notif_preview$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notification appearance'
	String get title => 'Notification appearance';

	/// en: 'Tuesday, 1 June'
	String get date => 'Tuesday, 1 June';

	/// en: 'now'
	String get rem_now => 'now';

	/// en: '⏰ Foliar spraying · 07:00'
	String get rem_title => '⏰ Foliar spraying · 07:00';

	/// en: 'Hedge + lawn · the morning is dry — a good time.'
	String get rem_body => 'Hedge + lawn · the morning is dry — a good time.';

	/// en: 'task reminder'
	String get rem_tag => 'task reminder';

	/// en: 'Tomorrow morning will be dry ☀️'
	String get wx_title => 'Tomorrow morning will be dry ☀️';

	/// en: 'A good time for foliar spraying of cherry laurels.'
	String get wx_body => 'A good time for foliar spraying of cherry laurels.';

	/// en: 'smart hint · weather'
	String get wx_tag => 'smart hint · weather';

	/// en: 'yesterday'
	String get com_yesterday => 'yesterday';

	/// en: 'Your area'
	String get com_title => 'Your area';

	/// en: '68% of gardeners near you fertilised their lawn for the first time this week.'
	String get com_body => '68% of gardeners near you fertilised their lawn for the first time this week.';

	/// en: 'nearby hint · V2'
	String get com_tag => 'nearby hint · V2';

	/// en: 'Tapping a notification opens the right screen (task · hint · nearby).'
	String get footer => 'Tapping a notification opens the right screen (task · hint · nearby).';
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip ›'
	String get skip => 'Skip ›';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Get started 🌿'
	String get start => 'Get started 🌿';

	/// en: 'soon (V2)'
	String get soon_badge => 'soon (V2)';

	/// en: 'Welcome to Tendask'
	String get welcome_title => 'Welcome to Tendask';

	/// en: 'Your simple diary for the garden, lawn and hedge — every task in one place.'
	String get welcome_body => 'Your simple diary for the garden, lawn and hedge — every task in one place.';

	/// en: 'Log it in seconds'
	String get log_title => 'Log it in seconds';

	/// en: 'Mowed, watered, fertilised? Note what, when and where — in a couple of taps. Weather is saved automatically.'
	String get log_body => 'Mowed, watered, fertilised? Note what, when and where — in a couple of taps. Weather is saved automatically.';

	/// en: 'Reminders + weather'
	String get remind_title => 'Reminders + weather';

	/// en: 'Plan tasks, get a reminder on your phone and a weather hint — "dry tomorrow morning, a good time to spray".'
	String get remind_body => 'Plan tasks, get a reminder on your phone and a weather hint — "dry tomorrow morning, a good time to spray".';

	/// en: 'Your area'
	String get nearby_title => 'Your area';

	/// en: 'Later: see what gardeners in a similar climate near you are doing — anonymous and private.'
	String get nearby_body => 'Later: see what gardeners in a similar climate near you are doing — anonymous and private.';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome to Tendask'
	String get title => 'Welcome to Tendask';

	/// en: 'Save your garden journal and don't lose your history when you change phones.'
	String get value_prop => 'Save your garden journal and don\'t lose your history when you change phones.';

	/// en: 'Continue with Apple'
	String get continue_apple => 'Continue with Apple';

	/// en: 'Continue with Google'
	String get continue_google => 'Continue with Google';

	/// en: 'Continue with email'
	String get continue_email => 'Continue with email';

	/// en: 'Try without an account'
	String get guest => 'Try without an account';

	/// en: 'We'll send a confirmation code by email (no password). Continuing means you agree to the terms and privacy policy.'
	String get legal => 'We\'ll send a confirmation code by email (no password). Continuing means you agree to the terms and privacy policy.';

	/// en: 'Without an account, all your data is lost if you remove the app or change device.'
	String get guest_warning => 'Without an account, all your data is lost if you remove the app or change device.';

	/// en: 'Google sign-in failed. Please try again.'
	String get google_error => 'Google sign-in failed. Please try again.';

	/// en: 'Coming soon.'
	String get coming_soon => 'Coming soon.';

	/// en: 'Privacy policy'
	String get privacy_link => 'Privacy policy';
}

// Path: email_login
class Translations$email_login$en {
	Translations$email_login$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in with email'
	String get title => 'Sign in with email';

	/// en: 'Email address'
	String get email_label => 'Email address';

	/// en: 'you@example.com'
	String get email_hint => 'you@example.com';

	/// en: 'Send code'
	String get send_code => 'Send code';

	/// en: 'We'll send you a one-time code — no password.'
	String get intro => 'We\'ll send you a one-time code — no password.';

	/// en: 'Code from email'
	String get code_label => 'Code from email';

	/// en: 'Enter the code you received'
	String get code_hint => 'Enter the code you received';

	/// en: 'We sent a code to $email. Enter it below.'
	String code_sent({required Object email}) => 'We sent a code to ${email}. Enter it below.';

	/// en: 'Confirm and sign in'
	String get verify => 'Confirm and sign in';

	/// en: 'Send a new code'
	String get resend => 'Send a new code';

	/// en: 'Enter a valid email address.'
	String get err_email => 'Enter a valid email address.';

	/// en: 'Enter the code from the email.'
	String get err_code => 'Enter the code from the email.';

	/// en: 'Couldn't send the code. Check your connection and try again.'
	String get err_send => 'Couldn\'t send the code. Check your connection and try again.';

	/// en: 'The code is wrong or has expired. Try again.'
	String get err_verify => 'The code is wrong or has expired. Try again.';

	/// en: 'We can't find that email's domain. Check the address.'
	String get err_email_domain => 'We can\'t find that email\'s domain. Check the address.';

	/// en: 'Did you mean $suggestion?'
	String did_you_mean({required Object suggestion}) => 'Did you mean ${suggestion}?';

	/// en: 'Send a new code ($seconds s)'
	String resend_in({required Object seconds}) => 'Send a new code (${seconds} s)';
}

// Path: location
class Translations$location$en {
	Translations$location$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Where do you garden?'
	String get title => 'Where do you garden?';

	/// en: 'We need your location for the local weather forecast and (later) to show you what gardeners in a similar climate are doing.'
	String get why => 'We need your location for the local weather forecast and (later) to show you what gardeners in a similar climate are doing.';

	/// en: 'Use my location'
	String get use_gps => 'Use my location';

	/// en: 'Enter a place'
	String get enter_place => 'Enter a place';

	/// en: 'or'
	String get or => 'or';

	/// en: 'Automatically via device GPS'
	String get gps_sub => 'Automatically via device GPS';

	/// en: 'Village, town or address (e.g. Šentjur)'
	String get place_hint => 'Village, town or address (e.g. Šentjur)';

	/// en: 'A village or town is enough — no exact address needed.'
	String get place_note => 'A village or town is enough — no exact address needed.';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'We never store your exact location. We only keep an approximate area (a wider region of a few km), which we never reveal to others.'
	String get privacy => 'We never store your exact location. We only keep an approximate area (a wider region of a few km), which we never reveal to others.';

	/// en: 'Continue'
	String get kContinue => 'Continue';

	/// en: 'Location set.'
	String get set_gps => 'Location set.';

	/// en: 'Location: $name'
	String set_place({required Object name}) => 'Location: ${name}';

	/// en: 'Location access denied. Enter a place or grant permission in system settings.'
	String get err_denied => 'Location access denied. Enter a place or grant permission in system settings.';

	/// en: 'Location services are off. Turn them on or enter a place.'
	String get err_disabled => 'Location services are off. Turn them on or enter a place.';

	/// en: 'Couldn't determine your location. Try again or enter a place.'
	String get err_unavailable => 'Couldn\'t determine your location. Try again or enter a place.';

	/// en: 'Search failed. Check your connection and try again.'
	String get err_search => 'Search failed. Check your connection and try again.';

	/// en: 'No matches for that place.'
	String get no_results => 'No matches for that place.';

	/// en: 'Garden location'
	String get screen_title => 'Garden location';

	/// en: 'Location is set'
	String get status_set => 'Location is set';

	/// en: 'Location is set · $name'
	String status_set_at({required Object name}) => 'Location is set · ${name}';

	/// en: 'Location not set yet'
	String get status_unset => 'Location not set yet';

	/// en: 'Remove location'
	String get clear => 'Remove location';

	/// en: 'Remove location?'
	String get clear_confirm_title => 'Remove location?';

	/// en: 'Weather will use the default region until you set a new location.'
	String get clear_confirm_body => 'Weather will use the default region until you set a new location.';

	/// en: 'Remove'
	String get clear_confirm_yes => 'Remove';

	/// en: 'Cancel'
	String get clear_confirm_cancel => 'Cancel';

	/// en: 'Location removed'
	String get cleared => 'Location removed';
}

// Path: journal
class Translations$journal$en {
	Translations$journal$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Journal'
	String get title => 'Journal';

	/// en: 'garden journal'
	String get subtitle => 'garden journal';

	/// en: 'All'
	String get filter_all => 'All';

	/// en: '✓ Tasks'
	String get filter_tasks => '✓ Tasks';

	/// en: '✍️ Notes'
	String get filter_notes => '✍️ Notes';

	/// en: 'No journal entries yet.'
	String get empty => 'No journal entries yet.';

	/// en: 'No completed tasks.'
	String get empty_tasks => 'No completed tasks.';

	/// en: 'No notes yet.'
	String get empty_notes => 'No notes yet.';

	/// en: 'Timeline'
	String get timeline => 'Timeline';

	/// en: 'Month'
	String get month_view => 'Month';

	/// en: '💡 Tap a day to view and add tasks.'
	String get month_hint => '💡 Tap a day to view and add tasks.';

	/// en: '(one) {$n task this month} (other) {$n tasks this month}'
	String month_count({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} task this month',
		other: '${n} tasks this month',
	);

	/// en: 'No tasks on this day.'
	String get day_empty => 'No tasks on this day.';

	/// en: 'Add task on this day'
	String get day_add => 'Add task on this day';
}

// Path: notes
class Translations$notes$en {
	Translations$notes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New note'
	String get title_new => 'New note';

	/// en: 'Edit note'
	String get title_edit => 'Edit note';

	/// en: 'Note'
	String get content_label => 'Note';

	/// en: 'Free text — observation, idea, thought…'
	String get content_hint => 'Free text — observation, idea, thought…';

	/// en: 'When'
	String get when => 'When';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'Date…'
	String get pick_date => 'Date…';

	/// en: 'Area (optional)'
	String get area => 'Area (optional)';

	/// en: 'No areas yet — add them in the Areas section.'
	String get no_areas => 'No areas yet — add them in the Areas section.';

	/// en: 'Plant (optional)'
	String get plant => 'Plant (optional)';

	/// en: 'Save note'
	String get save => 'Save note';

	/// en: 'Enter the note text.'
	String get err_content => 'Enter the note text.';

	/// en: 'Delete note'
	String get delete => 'Delete note';

	/// en: 'This action cannot be undone.'
	String get delete_confirm => 'This action cannot be undone.';

	/// en: '🌧️ Weather is saved automatically.'
	String get info => '🌧️ Weather is saved automatically.';
}

// Path: task_detail
class Translations$task_detail$en {
	Translations$task_detail$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weather snapshot'
	String get section_weather => 'Weather snapshot';

	/// en: 'Details'
	String get section_details => 'Details';

	/// en: 'Supplies'
	String get label_supplies => 'Supplies';

	/// en: 'Reminder'
	String get label_reminder => 'Reminder';

	/// en: 'Recurrence'
	String get label_recurrence => 'Recurrence';

	/// en: 'Note'
	String get label_note => 'Note';

	/// en: 'Planned'
	String get badge_waiting => 'Planned';

	/// en: 'Done'
	String get badge_done => 'Done';

	/// en: '✓ Mark as done'
	String get action_complete => '✓  Mark as done';

	/// en: '+1 day'
	String get action_postpone => '+1 day';

	/// en: 'Edit'
	String get action_edit => 'Edit';

	/// en: 'Duplicate'
	String get action_duplicate => 'Duplicate';

	/// en: 'Delete'
	String get action_delete => 'Delete';

	/// en: 'Back to waiting'
	String get action_revert => 'Back to waiting';

	/// en: 'Reschedule'
	String get action_move => 'Reschedule';

	/// en: 'Once'
	String get recurrence_once => 'Once';

	/// en: 'Weekly'
	String get recurrence_weekly => 'Weekly';

	/// en: 'Seasonal'
	String get recurrence_seasonal => 'Seasonal';

	/// en: '—'
	String get none => '—';

	/// en: 'Task not found.'
	String get not_found => 'Task not found.';
}

// Path: tasks_list
class Translations$tasks_list$en {
	Translations$tasks_list$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tasks'
	String get title => 'Tasks';

	/// en: 'upcoming and overdue'
	String get subtitle => 'upcoming and overdue';

	/// en: 'Overdue'
	String get section_overdue => 'Overdue';

	/// en: 'Today'
	String get section_today => 'Today';

	/// en: 'Tomorrow'
	String get section_tomorrow => 'Tomorrow';

	/// en: 'This week'
	String get section_this_week => 'This week';

	/// en: 'Later'
	String get section_later => 'Later';

	/// en: 'No pending tasks. Add one with +.'
	String get empty => 'No pending tasks. Add one with +.';

	/// en: '(one) {overdue 1 day} (other) {overdue $n days}'
	String overdue_days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'overdue 1 day',
		other: 'overdue ${n} days',
	);

	/// en: 'today'
	String get status_today => 'today';

	/// en: 'tomorrow'
	String get status_tomorrow => 'tomorrow';

	/// en: 'Complete'
	String get action_complete => 'Complete';

	/// en: '+1 day'
	String get action_postpone => '+1 day';

	/// en: 'Edit'
	String get action_edit => 'Edit';

	/// en: 'Duplicate'
	String get action_duplicate => 'Duplicate';

	/// en: 'Delete'
	String get action_delete => 'Delete';

	/// en: 'Delete task?'
	String get delete_confirm_title => 'Delete task?';

	/// en: 'This action cannot be undone.'
	String get delete_confirm_body => 'This action cannot be undone.';

	/// en: 'Delete'
	String get delete_yes => 'Delete';

	/// en: 'Cancel'
	String get delete_cancel => 'Cancel';
}

// Path: subject_picker
class Translations$subject_picker$en {
	Translations$subject_picker$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plant or area'
	String get title => 'Plant or area';

	/// en: 'Choose'
	String get choose => 'Choose';
}

// Path: entry
class Translations$entry$en {
	Translations$entry$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New task'
	String get title_new => 'New task';

	/// en: 'Review'
	String get title_review => 'Review';

	/// en: 'Continue'
	String get kContinue => 'Continue';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Save task'
	String get save => 'Save task';

	/// en: 'Step'
	String get step => 'Step';

	/// en: 'Just a note, no task?'
	String get note_card_title => 'Just a note, no task?';

	/// en: 'Note ›'
	String get note_card_action => 'Note ›';

	/// en: 'Repeat last'
	String get repeat_last => 'Repeat last';

	/// en: 'Which task?'
	String get type_title => 'Which task?';

	/// en: 'Tapping a task takes you forward automatically.'
	String get type_hint => 'Tapping a task takes you forward automatically.';

	/// en: 'Show all ($n)'
	String type_show_all({required Object n}) => 'Show all (${n})';

	/// en: 'Show less'
	String get type_show_less => 'Show less';

	/// en: 'For what?'
	String get subject_title => 'For what?';

	/// en: 'Search plant…'
	String get subject_search_hint => 'Search plant…';

	/// en: 'Plants'
	String get subject_plants => 'Plants';

	/// en: 'Add plant'
	String get subject_add_plant => 'Add plant';

	/// en: 'Add area'
	String get subject_add_area => 'Add area';

	/// en: 'Add from catalog'
	String get subject_from_catalog => 'Add from catalog';

	/// en: 'Areas:'
	String get subject_areas_context => 'Areas:';

	/// en: 'Or the whole area'
	String get subject_area_section => 'Or the whole area';

	/// en: 'Pick an area only when the task applies to the whole thing without a single plant (mowing, mulching a whole bed).'
	String get subject_area_note => 'Pick an area only when the task applies to the whole thing without a single plant (mowing, mulching a whole bed).';

	/// en: 'When'
	String get when_title => 'When';

	/// en: 'Today'
	String get when_today => 'Today';

	/// en: 'Tomorrow'
	String get when_tomorrow => 'Tomorrow';

	/// en: 'Date…'
	String get when_pick_date => 'Date…';

	/// en: 'Date'
	String get when_date => 'Date';

	/// en: 'Time'
	String get when_time => 'Time';

	/// en: 'Default: today at the next full hour.'
	String get when_default_note => 'Default: today at the next full hour.';

	/// en: 'Status'
	String get when_status => 'Status';

	/// en: 'Waiting'
	String get when_status_waiting => 'Waiting';

	/// en: 'Done'
	String get when_status_done => 'Done';

	/// en: 'Default derived from the date and time: future = waiting, otherwise = done.'
	String get when_status_note => 'Default derived from the date and time: future = waiting, otherwise = done.';

	/// en: 'Reminder'
	String get reminder_title => 'Reminder';

	/// en: '(optional)'
	String get optional => '(optional)';

	/// en: 'This step is here because the task is planned (Waiting). A reminder notifies you on your phone at the chosen time.'
	String get reminder_why => 'This step is here because the task is planned (Waiting). A reminder notifies you on your phone at the chosen time.';

	/// en: 'Add reminder'
	String get reminder_add => 'Add reminder';

	/// en: 'Adjustable offset and time. Several reminders per task.'
	String get reminder_note => 'Adjustable offset and time. Several reminders per task.';

	/// en: 'Supplies'
	String get supplies_title => 'Supplies';

	/// en: 'This step is here because the task usually consumes supplies. They are deducted from stock.'
	String get supplies_why => 'This step is here because the task usually consumes supplies. They are deducted from stock.';

	/// en: 'Add supply from stock'
	String get supplies_add => 'Add supply from stock';

	/// en: 'One mix for all selected plants — deducted once.'
	String get supplies_note => 'One mix for all selected plants — deducted once.';

	/// en: 'Check it over — tap a row to edit'
	String get review_title => 'Check it over — tap a row to edit';

	/// en: 'Task'
	String get review_type => 'Task';

	/// en: 'For what'
	String get review_subject => 'For what';

	/// en: 'When'
	String get review_when => 'When';

	/// en: 'Reminder'
	String get review_reminder => 'Reminder';

	/// en: 'Supplies'
	String get review_supplies => 'Supplies';

	/// en: 'Edit'
	String get review_fix => 'Edit';

	/// en: '—'
	String get review_none => '—';

	/// en: 'Note'
	String get note_label => 'Note';

	/// en: 'e.g. in the morning before forecast rain'
	String get note_hint => 'e.g. in the morning before forecast rain';

	/// en: '🌧️ Weather is saved automatically on completion.'
	String get weather_note => '🌧️ Weather is saved automatically on completion.';

	/// en: 'Pick at least one plant or area.'
	String get err_subject => 'Pick at least one plant or area.';

	/// en: 'At event time'
	String get rem_event => 'At event time';

	/// en: '10 minutes before'
	String get rem_10min => '10 minutes before';

	/// en: '1 hour before'
	String get rem_1hour => '1 hour before';

	/// en: '1 day before'
	String get rem_1day => '1 day before';

	/// en: '2 days before'
	String get rem_2day => '2 days before';

	/// en: 'Custom…'
	String get rem_custom => 'Custom…';

	/// en: 'min'
	String get rem_unit_min => 'min';

	/// en: 'hrs'
	String get rem_unit_hour => 'hrs';

	/// en: 'days'
	String get rem_unit_day => 'days';

	/// en: 'How long before?'
	String get rem_custom_label => 'How long before?';

	/// en: 'before'
	String get rem_before => 'before';

	/// en: 'at $t'
	String rem_at({required Object t}) => 'at ${t}';

	/// en: 'At time'
	String get rem_choose_time => 'At time';

	/// en: 'The time applies to day-based offsets (e.g. "1 day before at 18:00").'
	String get rem_time_note => 'The time applies to day-based offsets (e.g. "1 day before at 18:00").';

	/// en: 'Notifications are disabled, so a reminder can't be added.'
	String get rem_perm_denied => 'Notifications are disabled, so a reminder can\'t be added.';

	/// en: 'Allow exact reminders'
	String get rem_exact_title => 'Allow exact reminders';

	/// en: 'To fire at the exact time, Tendask needs the "Alarms & reminders" permission. Enable it in settings, then add the reminder again.'
	String get rem_exact_body => 'To fire at the exact time, Tendask needs the "Alarms & reminders" permission. Enable it in settings, then add the reminder again.';

	/// en: 'Open settings'
	String get rem_exact_open => 'Open settings';

	/// en: 'already added'
	String get rem_added => 'already added';
}

// Path: plant_edit
class Translations$plant_edit$en {
	Translations$plant_edit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit plant'
	String get title_edit => 'Edit plant';

	/// en: 'Species'
	String get species => 'Species';

	/// en: 'Personal name (optional)'
	String get alias => 'Personal name (optional)';

	/// en: 'e.g. “old apple by the fence”'
	String get alias_hint => 'e.g. “old apple by the fence”';

	/// en: 'Only you see it; shown instead of the default name.'
	String get alias_note => 'Only you see it; shown instead of the default name.';

	/// en: 'Area'
	String get location_label => 'Area';

	/// en: 'Remove plant from garden'
	String get delete => 'Remove plant from garden';

	/// en: 'Task history stays in the journal.'
	String get delete_note => 'Task history stays in the journal.';

	/// en: 'Save'
	String get save => 'Save';
}

// Path: plant_detail
class Translations$plant_detail$en {
	Translations$plant_detail$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plant not found.'
	String get not_found => 'Plant not found.';

	/// en: 'Task history'
	String get history_title => 'Task history';

	/// en: 'No tasks for this plant yet.'
	String get history_empty => 'No tasks for this plant yet.';

	/// en: 'move'
	String get move => 'move';

	/// en: 'Assign area'
	String get assign_area => 'Assign area';
}

// Path: area_pick
class Translations$area_pick$en {
	Translations$area_pick$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Move “$name”'
	String move_title({required Object name}) => 'Move “${name}”';

	/// en: 'Choose area'
	String get choose_title => 'Choose area';

	/// en: 'A plant lives in one area (or none). Its task history stays.'
	String get note => 'A plant lives in one area (or none). Its task history stays.';

	/// en: 'No area'
	String get none => 'No area';

	/// en: 'current'
	String get current => 'current';

	/// en: 'New area'
	String get new_area => 'New area';

	/// en: 'This plant is already in the selected area.'
	String get duplicate => 'This plant is already in the selected area.';
}

// Path: areas
class Translations$areas$en {
	Translations$areas$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Garden'
	String get title => 'Garden';

	/// en: 'plants and lawns'
	String get subtitle => 'plants and lawns';

	/// en: 'No area'
	String get unassigned => 'No area';

	/// en: 'last:'
	String get last_prefix => 'last:';

	/// en: 'Garden'
	String get type_garden => 'Garden';

	/// en: 'Lawn'
	String get type_lawn => 'Lawn';

	/// en: 'Hedge'
	String get type_hedge => 'Hedge';

	/// en: 'Bed'
	String get type_bed => 'Bed';

	/// en: 'Fruit tree'
	String get type_tree => 'Fruit tree';

	/// en: 'Ornamental'
	String get type_ornamental => 'Ornamental';

	/// en: 'Other'
	String get type_other => 'Other';

	/// en: 'Garden'
	String get default_garden_name => 'Garden';

	/// en: 'Task history'
	String get history_title => 'Task history';

	/// en: 'No tasks in this area yet.'
	String get history_empty => 'No tasks in this area yet.';

	/// en: 'Plants'
	String get plants_section => 'Plants';

	/// en: 'Add plant to $area'
	String add_plant_here({required Object area}) => 'Add plant to ${area}';

	/// en: 'Plants in this area move to “No area” (they are not deleted).'
	String get delete_reparent_note => 'Plants in this area move to “No area” (they are not deleted).';

	/// en: 'New area'
	String get new_area_inline => 'New area';

	/// en: 'Your garden is empty'
	String get empty_title => 'Your garden is empty';

	/// en: 'Add the plants you have. Areas (beds, lawns) are optional.'
	String get empty_body => 'Add the plants you have. Areas (beds, lawns) are optional.';

	/// en: 'Add plants'
	String get empty_cta_plant => 'Add plants';

	/// en: 'Add area'
	String get empty_cta_area => 'Add area';

	/// en: 'Edit'
	String get action_edit => 'Edit';

	/// en: 'Delete'
	String get action_delete => 'Delete';

	/// en: 'Delete area?'
	String get delete_confirm_title => 'Delete area?';

	/// en: 'Tasks remain but lose their link to this area.'
	String get delete_confirm_body => 'Tasks remain but lose their link to this area.';

	/// en: 'New area'
	String get form_title_new => 'New area';

	/// en: 'Edit area'
	String get form_title_edit => 'Edit area';

	/// en: 'Name'
	String get form_name => 'Name';

	/// en: 'e.g. Raised bed 1'
	String get form_name_hint => 'e.g. Raised bed 1';

	/// en: 'Type'
	String get form_type => 'Type';

	/// en: 'Save area'
	String get form_save => 'Save area';

	/// en: 'Enter an area name.'
	String get err_name => 'Enter an area name.';
}

// Path: plants
class Translations$plants$en {
	Translations$plants$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select plant'
	String get picker_title => 'Select plant';

	/// en: 'Search plant…'
	String get search_hint => 'Search plant…';

	/// en: 'All'
	String get cat_all => 'All';

	/// en: 'Fruit trees'
	String get cat_fruit_tree => 'Fruit trees';

	/// en: 'Berries'
	String get cat_berries => 'Berries';

	/// en: 'Vegetables'
	String get cat_vegetable => 'Vegetables';

	/// en: 'Herbs'
	String get cat_herbs => 'Herbs';

	/// en: 'Ornamental'
	String get cat_ornamental => 'Ornamental';

	/// en: 'Houseplants'
	String get cat_houseplant => 'Houseplants';

	/// en: 'Lawn'
	String get cat_lawn => 'Lawn';

	/// en: 'From catalog'
	String get from_catalog => 'From catalog';

	/// en: 'Can't find it?'
	String get not_found => 'Can\'t find it?';

	/// en: '+ Add custom: “$q”'
	String custom_add({required Object q}) => '+ Add custom: “${q}”';

	/// en: 'A custom entry is private and not shared with the community.'
	String get custom_private => 'A custom entry is private and not shared with the community.';

	/// en: 'Add plants'
	String get add_title => 'Add plants';

	/// en: 'Frequent'
	String get frequent => 'Frequent';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Add to'
	String get add_to_label => 'Add to';

	/// en: 'choose'
	String get choose_area => 'choose';

	/// en: 'Select plant'
	String get field_add => 'Select plant';

	/// en: 'This area has no plants yet. Add one with the button below.'
	String get field_empty => 'This area has no plants yet. Add one with the button below.';
}

// Path: supplies
class Translations$supplies$en {
	Translations$supplies$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Supplies'
	String get title => 'Supplies';

	/// en: 'what I have at home'
	String get subtitle => 'what I have at home';

	/// en: 'No supplies yet. Add some with +.'
	String get empty => 'No supplies yet. Add some with +.';

	/// en: 'low'
	String get low => 'low';

	/// en: '~$q$unit'
	String qty({required Object q, required Object unit}) => '~${q}${unit}';

	/// en: 'New supply'
	String get form_new => 'New supply';

	/// en: 'Edit supply'
	String get form_edit => 'Edit supply';

	/// en: 'Name'
	String get form_name => 'Name';

	/// en: 'Quantity'
	String get form_quantity => 'Quantity';

	/// en: 'Unit'
	String get form_unit => 'Unit';

	/// en: 'Warn at (threshold)'
	String get form_threshold => 'Warn at (threshold)';

	/// en: 'Save'
	String get form_save => 'Save';

	/// en: 'Enter a supply name.'
	String get err_name => 'Enter a supply name.';

	/// en: 'Add supply'
	String get add_to_task => 'Add supply';

	/// en: 'New supply'
	String get pick_new => 'New supply';

	/// en: 'Amount used'
	String get amount => 'Amount used';

	/// en: 'Add'
	String get add_confirm => 'Add';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Guest (not signed in)'
	String get profile_guest => 'Guest (not signed in)';

	/// en: 'Sign in to back up your data'
	String get sign_in_prompt => 'Sign in to back up your data';

	/// en: 'Signed in — data backed up'
	String get signed_in => 'Signed in — data backed up';

	/// en: 'Location'
	String get section_location => 'Location';

	/// en: 'Weather location'
	String get location_placeholder => 'Weather location';

	/// en: 'Language'
	String get section_language => 'Language';

	/// en: 'Notifications'
	String get section_notifications => 'Notifications';

	/// en: 'Notifications and reminders'
	String get notifications_placeholder => 'Notifications and reminders';

	/// en: 'Suggestions'
	String get section_suggestions => 'Suggestions';

	/// en: 'What was suggested and how you responded'
	String get suggestions_history_sub => 'What was suggested and how you responded';

	/// en: 'Garden'
	String get section_garden => 'Garden';

	/// en: '📦 Supplies'
	String get supplies => '📦 Supplies';

	/// en: 'urea, algae, fertilizers, gear'
	String get supplies_sub => 'urea, algae, fertilizers, gear';

	/// en: 'Account & data'
	String get section_account => 'Account & data';

	/// en: 'Export data (GDPR)'
	String get export_data => 'Export data (GDPR)';

	/// en: 'Sign out'
	String get logout => 'Sign out';

	/// en: 'Sign out?'
	String get logout_confirm_title => 'Sign out?';

	/// en: 'Signs you out and clears local data from this device. Synced data stays in the cloud and returns when you sign in again with the same account.'
	String get logout_confirm_body => 'Signs you out and clears local data from this device. Synced data stays in the cloud and returns when you sign in again with the same account.';

	/// en: 'Cancel'
	String get logout_cancel => 'Cancel';

	/// en: 'Can't sign out while offline — your data isn't saved to the cloud yet. Try again when you're connected.'
	String get logout_offline => 'Can\'t sign out while offline — your data isn\'t saved to the cloud yet. Try again when you\'re connected.';

	/// en: 'Tendask data export'
	String get export_share_text => 'Tendask data export';

	/// en: 'Export failed. Please try again.'
	String get export_error => 'Export failed. Please try again.';

	/// en: 'Delete account and all data'
	String get delete_account => 'Delete account and all data';

	/// en: 'Delete account?'
	String get delete_account_confirm_title => 'Delete account?';

	/// en: 'Permanently deletes your account and all data (tasks, areas, plants, notes) — both in the cloud and on this device. This cannot be undone.'
	String get delete_account_confirm_body => 'Permanently deletes your account and all data (tasks, areas, plants, notes) — both in the cloud and on this device. This cannot be undone.';

	/// en: 'Delete account'
	String get delete_account_confirm => 'Delete account';

	/// en: 'Deletion failed. Try again when you're connected.'
	String get delete_account_error => 'Deletion failed. Try again when you\'re connected.';

	/// en: 'Delete all data on this device'
	String get delete_data => 'Delete all data on this device';

	/// en: 'Delete all data?'
	String get delete_data_confirm_title => 'Delete all data?';

	/// en: 'Permanently deletes all data on this device (tasks, areas, plants, notes). This cannot be undone.'
	String get delete_data_confirm_body => 'Permanently deletes all data on this device (tasks, areas, plants, notes). This cannot be undone.';

	/// en: 'Delete'
	String get delete_data_confirm => 'Delete';

	/// en: 'About'
	String get section_about => 'About';

	/// en: 'Privacy policy'
	String get privacy_policy => 'Privacy policy';
}

// Path: weather
class Translations$weather$en {
	Translations$weather$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Clear'
	String get cond_clear => 'Clear';

	/// en: 'Mostly clear'
	String get cond_mainly_clear => 'Mostly clear';

	/// en: 'Cloudy'
	String get cond_cloudy => 'Cloudy';

	/// en: 'Fog'
	String get cond_fog => 'Fog';

	/// en: 'Drizzle'
	String get cond_drizzle => 'Drizzle';

	/// en: 'Rain'
	String get cond_rain => 'Rain';

	/// en: 'Snow'
	String get cond_snow => 'Snow';

	/// en: 'Showers'
	String get cond_showers => 'Showers';

	/// en: 'Thunderstorm'
	String get cond_thunderstorm => 'Thunderstorm';

	/// en: '—'
	String get cond_unknown => '—';

	/// en: 'Forecast'
	String get band_forecast => 'Forecast';

	/// en: 'Rain last 48 h:'
	String get rain_past48h => 'Rain last 48 h:';

	/// en: 'Weather will be recorded when you mark the task done.'
	String get detail_waiting => 'Weather will be recorded when you mark the task done.';

	/// en: 'No weather snapshot (was offline at the time).'
	String get detail_none => 'No weather snapshot (was offline at the time).';

	/// en: 'Weather is currently unavailable.'
	String get home_unavailable => 'Weather is currently unavailable.';

	/// en: 'Tap to retry'
	String get home_retry => 'Tap to retry';

	/// en: 'Loading weather…'
	String get loading => 'Loading weather…';

	/// en: 'Updated $time'
	String updated_at({required Object time}) => 'Updated ${time}';

	/// en: 'Humidity'
	String get m_humidity => 'Humidity';

	/// en: 'Wind'
	String get m_wind => 'Wind';

	/// en: 'Precipitation'
	String get m_precipitation => 'Precipitation';

	/// en: 'Soil temp.'
	String get m_soil_temp => 'Soil temp.';

	/// en: 'ET₀'
	String get m_et0 => 'ET₀';

	/// en: 'Rain 48 h'
	String get m_rain48h => 'Rain 48 h';

	/// en: 'no rain'
	String get m_no_rain => 'no rain';
}

// Path: suggestions
class Translations$suggestions$en {
	Translations$suggestions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$actions$en actions = Translations$suggestions$actions$en.internal(_root);
	late final Translations$suggestions$toast$en toast = Translations$suggestions$toast$en.internal(_root);

	/// en: 'Suggestions are general guidance — you know your garden best.'
	String get disclaimer => 'Suggestions are general guidance — you know your garden best.';

	late final Translations$suggestions$done_sheet$en done_sheet = Translations$suggestions$done_sheet$en.internal(_root);
	late final Translations$suggestions$remove$en remove = Translations$suggestions$remove$en.internal(_root);
	late final Translations$suggestions$history_status$en history_status = Translations$suggestions$history_status$en.internal(_root);

	/// en: 'Suggestions for you'
	String get band_title => 'Suggestions for you';

	/// en: 'History'
	String get past_link => 'History';

	/// en: 'Past suggestions'
	String get past_title => 'Past suggestions';

	/// en: 'What Tendask suggested and how you responded.'
	String get past_intro => 'What Tendask suggested and how you responded.';

	/// en: 'No history yet. When you respond to a suggestion — plan it, skip it or log it as done — it appears here.'
	String get past_empty => 'No history yet. When you respond to a suggestion — plan it, skip it or log it as done — it appears here.';

	/// en: 'Suggestions older than a year are cleared automatically.'
	String get past_retention => 'Suggestions older than a year are cleared automatically.';

	late final Translations$suggestions$cadence$en cadence = Translations$suggestions$cadence$en.internal(_root);
	late final Translations$suggestions$history$en history = Translations$suggestions$history$en.internal(_root);
	late final Translations$suggestions$weather$en weather = Translations$suggestions$weather$en.internal(_root);
	late final Translations$suggestions$community$en community = Translations$suggestions$community$en.internal(_root);
	late final Translations$suggestions$lawn$en lawn = Translations$suggestions$lawn$en.internal(_root);
	late final Translations$suggestions$fruit_tree$en fruit_tree = Translations$suggestions$fruit_tree$en.internal(_root);
	late final Translations$suggestions$berries$en berries = Translations$suggestions$berries$en.internal(_root);
	late final Translations$suggestions$vegetable$en vegetable = Translations$suggestions$vegetable$en.internal(_root);
	late final Translations$suggestions$herbs$en herbs = Translations$suggestions$herbs$en.internal(_root);
	late final Translations$suggestions$tomato$en tomato = Translations$suggestions$tomato$en.internal(_root);
	late final Translations$suggestions$shrub$en shrub = Translations$suggestions$shrub$en.internal(_root);
	late final Translations$suggestions$hedge$en hedge = Translations$suggestions$hedge$en.internal(_root);
	late final Translations$suggestions$conifer$en conifer = Translations$suggestions$conifer$en.internal(_root);
	late final Translations$suggestions$houseplant$en houseplant = Translations$suggestions$houseplant$en.internal(_root);
	late final Translations$suggestions$blueberry$en blueberry = Translations$suggestions$blueberry$en.internal(_root);
	late final Translations$suggestions$cherry_laurel$en cherry_laurel = Translations$suggestions$cherry_laurel$en.internal(_root);
	late final Translations$suggestions$hydrangea$en hydrangea = Translations$suggestions$hydrangea$en.internal(_root);
	late final Translations$suggestions$peach$en peach = Translations$suggestions$peach$en.internal(_root);
	late final Translations$suggestions$raspberry$en raspberry = Translations$suggestions$raspberry$en.internal(_root);
	late final Translations$suggestions$rose$en rose = Translations$suggestions$rose$en.internal(_root);
	late final Translations$suggestions$cucumber$en cucumber = Translations$suggestions$cucumber$en.internal(_root);
	late final Translations$suggestions$zucchini$en zucchini = Translations$suggestions$zucchini$en.internal(_root);
}

// Path: suggestions.actions
class Translations$suggestions$actions$en {
	Translations$suggestions$actions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plan'
	String get plan => 'Plan';

	/// en: 'Skip'
	String get dismiss => 'Skip';

	/// en: 'Already done'
	String get already_done => 'Already done';

	/// en: 'Don't suggest this again'
	String get never => 'Don\'t suggest this again';

	/// en: 'I no longer have this'
	String get remove_subject => 'I no longer have this';
}

// Path: suggestions.toast
class Translations$suggestions$toast$en {
	Translations$suggestions$toast$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Added to your tasks'
	String get planned => 'Added to your tasks';

	/// en: 'Logged as done'
	String get logged => 'Logged as done';
}

// Path: suggestions.done_sheet
class Translations$suggestions$done_sheet$en {
	Translations$suggestions$done_sheet$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'When did you do it?'
	String get title => 'When did you do it?';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'Pick a date…'
	String get pick => 'Pick a date…';
}

// Path: suggestions.remove
class Translations$suggestions$remove$en {
	Translations$suggestions$remove$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Remove this?'
	String get title => 'Remove this?';

	/// en: 'This removes {subject} from your garden and stops its suggestions. Your past records stay.'
	String get body => 'This removes {subject} from your garden and stops its suggestions. Your past records stay.';

	/// en: 'Remove'
	String get confirm => 'Remove';
}

// Path: suggestions.history_status
class Translations$suggestions$history_status$en {
	Translations$suggestions$history_status$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Planned'
	String get planned => 'Planned';

	/// en: 'Logged'
	String get logged => 'Logged';

	/// en: 'Dismissed'
	String get dismissed => 'Dismissed';

	/// en: 'Muted'
	String get muted => 'Muted';

	/// en: 'Missed'
	String get missed => 'Missed';
}

// Path: suggestions.cadence
class Translations$suggestions$cadence$en {
	Translations$suggestions$cadence$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$cadence$overdue$en overdue = Translations$suggestions$cadence$overdue$en.internal(_root);
}

// Path: suggestions.history
class Translations$suggestions$history$en {
	Translations$suggestions$history$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$history$anniversary$en anniversary = Translations$suggestions$history$anniversary$en.internal(_root);
}

// Path: suggestions.weather
class Translations$suggestions$weather$en {
	Translations$suggestions$weather$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$weather$window_open$en window_open = Translations$suggestions$weather$window_open$en.internal(_root);
}

// Path: suggestions.community
class Translations$suggestions$community$en {
	Translations$suggestions$community$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$community$most_started$en most_started = Translations$suggestions$community$most_started$en.internal(_root);
}

// Path: suggestions.lawn
class Translations$suggestions$lawn$en {
	Translations$suggestions$lawn$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$lawn$mow_due$en mow_due = Translations$suggestions$lawn$mow_due$en.internal(_root);
	late final Translations$suggestions$lawn$water_drought$en water_drought = Translations$suggestions$lawn$water_drought$en.internal(_root);
	late final Translations$suggestions$lawn$fertilize_spring$en fertilize_spring = Translations$suggestions$lawn$fertilize_spring$en.internal(_root);
	late final Translations$suggestions$lawn$fertilize_autumn$en fertilize_autumn = Translations$suggestions$lawn$fertilize_autumn$en.internal(_root);
	late final Translations$suggestions$lawn$lime$en lime = Translations$suggestions$lawn$lime$en.internal(_root);
	late final Translations$suggestions$lawn$moss_control$en moss_control = Translations$suggestions$lawn$moss_control$en.internal(_root);
	late final Translations$suggestions$lawn$weed_control$en weed_control = Translations$suggestions$lawn$weed_control$en.internal(_root);
	late final Translations$suggestions$lawn$overseed_spring$en overseed_spring = Translations$suggestions$lawn$overseed_spring$en.internal(_root);
	late final Translations$suggestions$lawn$overseed_autumn$en overseed_autumn = Translations$suggestions$lawn$overseed_autumn$en.internal(_root);
	late final Translations$suggestions$lawn$scarify_spring$en scarify_spring = Translations$suggestions$lawn$scarify_spring$en.internal(_root);
	late final Translations$suggestions$lawn$scarify_autumn$en scarify_autumn = Translations$suggestions$lawn$scarify_autumn$en.internal(_root);
	late final Translations$suggestions$lawn$aerate$en aerate = Translations$suggestions$lawn$aerate$en.internal(_root);
	late final Translations$suggestions$lawn$roll$en roll = Translations$suggestions$lawn$roll$en.internal(_root);
	late final Translations$suggestions$lawn$topdress$en topdress = Translations$suggestions$lawn$topdress$en.internal(_root);
}

// Path: suggestions.fruit_tree
class Translations$suggestions$fruit_tree$en {
	Translations$suggestions$fruit_tree$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$fruit_tree$fertilize_spring$en fertilize_spring = Translations$suggestions$fruit_tree$fertilize_spring$en.internal(_root);
	late final Translations$suggestions$fruit_tree$prune_winter$en prune_winter = Translations$suggestions$fruit_tree$prune_winter$en.internal(_root);
	late final Translations$suggestions$fruit_tree$treat_dormant$en treat_dormant = Translations$suggestions$fruit_tree$treat_dormant$en.internal(_root);
	late final Translations$suggestions$fruit_tree$mulch$en mulch = Translations$suggestions$fruit_tree$mulch$en.internal(_root);
	late final Translations$suggestions$fruit_tree$thin_fruit$en thin_fruit = Translations$suggestions$fruit_tree$thin_fruit$en.internal(_root);
	late final Translations$suggestions$fruit_tree$graft_spring$en graft_spring = Translations$suggestions$fruit_tree$graft_spring$en.internal(_root);
	late final Translations$suggestions$fruit_tree$graft_budding$en graft_budding = Translations$suggestions$fruit_tree$graft_budding$en.internal(_root);
}

// Path: suggestions.berries
class Translations$suggestions$berries$en {
	Translations$suggestions$berries$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$berries$prune_winter$en prune_winter = Translations$suggestions$berries$prune_winter$en.internal(_root);
	late final Translations$suggestions$berries$fertilize_spring$en fertilize_spring = Translations$suggestions$berries$fertilize_spring$en.internal(_root);
	late final Translations$suggestions$berries$mulch$en mulch = Translations$suggestions$berries$mulch$en.internal(_root);
	late final Translations$suggestions$berries$treat_dormant$en treat_dormant = Translations$suggestions$berries$treat_dormant$en.internal(_root);
}

// Path: suggestions.vegetable
class Translations$suggestions$vegetable$en {
	Translations$suggestions$vegetable$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$vegetable$start_seedlings$en start_seedlings = Translations$suggestions$vegetable$start_seedlings$en.internal(_root);
	late final Translations$suggestions$vegetable$prick_out$en prick_out = Translations$suggestions$vegetable$prick_out$en.internal(_root);
	late final Translations$suggestions$vegetable$harden_off$en harden_off = Translations$suggestions$vegetable$harden_off$en.internal(_root);
	late final Translations$suggestions$vegetable$plant_out$en plant_out = Translations$suggestions$vegetable$plant_out$en.internal(_root);
	late final Translations$suggestions$vegetable$transplant$en transplant = Translations$suggestions$vegetable$transplant$en.internal(_root);
	late final Translations$suggestions$vegetable$sow_direct$en sow_direct = Translations$suggestions$vegetable$sow_direct$en.internal(_root);
	late final Translations$suggestions$vegetable$fertilize_season$en fertilize_season = Translations$suggestions$vegetable$fertilize_season$en.internal(_root);
	late final Translations$suggestions$vegetable$treat_window$en treat_window = Translations$suggestions$vegetable$treat_window$en.internal(_root);
}

// Path: suggestions.herbs
class Translations$suggestions$herbs$en {
	Translations$suggestions$herbs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$herbs$start_seedlings$en start_seedlings = Translations$suggestions$herbs$start_seedlings$en.internal(_root);
	late final Translations$suggestions$herbs$sow_direct$en sow_direct = Translations$suggestions$herbs$sow_direct$en.internal(_root);
	late final Translations$suggestions$herbs$plant_out$en plant_out = Translations$suggestions$herbs$plant_out$en.internal(_root);
}

// Path: suggestions.tomato
class Translations$suggestions$tomato$en {
	Translations$suggestions$tomato$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$tomato$start_seedlings$en start_seedlings = Translations$suggestions$tomato$start_seedlings$en.internal(_root);
	late final Translations$suggestions$tomato$prick_out$en prick_out = Translations$suggestions$tomato$prick_out$en.internal(_root);
	late final Translations$suggestions$tomato$harden_off$en harden_off = Translations$suggestions$tomato$harden_off$en.internal(_root);
	late final Translations$suggestions$tomato$transplant$en transplant = Translations$suggestions$tomato$transplant$en.internal(_root);
	late final Translations$suggestions$tomato$stake$en stake = Translations$suggestions$tomato$stake$en.internal(_root);
}

// Path: suggestions.shrub
class Translations$suggestions$shrub$en {
	Translations$suggestions$shrub$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$shrub$prune_spring$en prune_spring = Translations$suggestions$shrub$prune_spring$en.internal(_root);
	late final Translations$suggestions$shrub$overwinter$en overwinter = Translations$suggestions$shrub$overwinter$en.internal(_root);
}

// Path: suggestions.hedge
class Translations$suggestions$hedge$en {
	Translations$suggestions$hedge$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$hedge$prune_early_summer$en prune_early_summer = Translations$suggestions$hedge$prune_early_summer$en.internal(_root);
	late final Translations$suggestions$hedge$prune_late_summer$en prune_late_summer = Translations$suggestions$hedge$prune_late_summer$en.internal(_root);
}

// Path: suggestions.conifer
class Translations$suggestions$conifer$en {
	Translations$suggestions$conifer$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$conifer$prune$en prune = Translations$suggestions$conifer$prune$en.internal(_root);
}

// Path: suggestions.houseplant
class Translations$suggestions$houseplant$en {
	Translations$suggestions$houseplant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$houseplant$repot$en repot = Translations$suggestions$houseplant$repot$en.internal(_root);
	late final Translations$suggestions$houseplant$fertilize_season$en fertilize_season = Translations$suggestions$houseplant$fertilize_season$en.internal(_root);
	late final Translations$suggestions$houseplant$overwinter$en overwinter = Translations$suggestions$houseplant$overwinter$en.internal(_root);
}

// Path: suggestions.blueberry
class Translations$suggestions$blueberry$en {
	Translations$suggestions$blueberry$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$blueberry$prune$en prune = Translations$suggestions$blueberry$prune$en.internal(_root);
}

// Path: suggestions.cherry_laurel
class Translations$suggestions$cherry_laurel$en {
	Translations$suggestions$cherry_laurel$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$cherry_laurel$prune_late_spring$en prune_late_spring = Translations$suggestions$cherry_laurel$prune_late_spring$en.internal(_root);
	late final Translations$suggestions$cherry_laurel$prune_late_summer$en prune_late_summer = Translations$suggestions$cherry_laurel$prune_late_summer$en.internal(_root);
}

// Path: suggestions.hydrangea
class Translations$suggestions$hydrangea$en {
	Translations$suggestions$hydrangea$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$hydrangea$prune_old_wood$en prune_old_wood = Translations$suggestions$hydrangea$prune_old_wood$en.internal(_root);
	late final Translations$suggestions$hydrangea$prune_new_wood$en prune_new_wood = Translations$suggestions$hydrangea$prune_new_wood$en.internal(_root);
}

// Path: suggestions.peach
class Translations$suggestions$peach$en {
	Translations$suggestions$peach$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$peach$prune_spring$en prune_spring = Translations$suggestions$peach$prune_spring$en.internal(_root);
}

// Path: suggestions.raspberry
class Translations$suggestions$raspberry$en {
	Translations$suggestions$raspberry$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$raspberry$prune_late_winter$en prune_late_winter = Translations$suggestions$raspberry$prune_late_winter$en.internal(_root);
	late final Translations$suggestions$raspberry$prune_after_harvest$en prune_after_harvest = Translations$suggestions$raspberry$prune_after_harvest$en.internal(_root);
}

// Path: suggestions.rose
class Translations$suggestions$rose$en {
	Translations$suggestions$rose$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$rose$prune_spring$en prune_spring = Translations$suggestions$rose$prune_spring$en.internal(_root);
	late final Translations$suggestions$rose$overwinter$en overwinter = Translations$suggestions$rose$overwinter$en.internal(_root);
}

// Path: suggestions.cucumber
class Translations$suggestions$cucumber$en {
	Translations$suggestions$cucumber$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$cucumber$sow_direct$en sow_direct = Translations$suggestions$cucumber$sow_direct$en.internal(_root);
}

// Path: suggestions.zucchini
class Translations$suggestions$zucchini$en {
	Translations$suggestions$zucchini$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$suggestions$zucchini$sow_direct$en sow_direct = Translations$suggestions$zucchini$sow_direct$en.internal(_root);
}

// Path: suggestions.cadence.overdue
class Translations$suggestions$cadence$overdue$en {
	Translations$suggestions$cadence$overdue$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{task} is due'
	String get title => '{task} is due';

	/// en: '{subject} is about {days_overdue} days past the usual ~{cadence_days}-day rhythm.'
	String get body => '{subject} is about {days_overdue} days past the usual ~{cadence_days}-day rhythm.';
}

// Path: suggestions.history.anniversary
class Translations$suggestions$history$anniversary$en {
	Translations$suggestions$history$anniversary$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{task} — a year ago'
	String get title => '{task} — a year ago';

	/// en: 'Last year around {last_year_date} — {task} for {subject}. Worth repeating?'
	String get body => 'Last year around {last_year_date} — {task} for {subject}. Worth repeating?';
}

// Path: suggestions.weather.window_open
class Translations$suggestions$weather$window_open$en {
	Translations$suggestions$weather$window_open$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{task}: good window'
	String get title => '{task}: good window';

	/// en: 'A dry spell is on the way for {subject} — a good time to do it.'
	String get body => 'A dry spell is on the way for {subject} — a good time to do it.';
}

// Path: suggestions.community.most_started
class Translations$suggestions$community$most_started$en {
	Translations$suggestions$community$most_started$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{task} nearby'
	String get title => '{task} nearby';

	/// en: 'About {percent}% of gardeners near you have started this so far this season.'
	String get body => 'About {percent}% of gardeners near you have started this so far this season.';
}

// Path: suggestions.lawn.mow_due
class Translations$suggestions$lawn$mow_due$en {
	Translations$suggestions$lawn$mow_due$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mowing due'
	String get title => 'Mowing due';

	/// en: '{subject} is ready for a mow.'
	String get body => '{subject} is ready for a mow.';
}

// Path: suggestions.lawn.water_drought
class Translations$suggestions$lawn$water_drought$en {
	Translations$suggestions$lawn$water_drought$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Water in the dry spell'
	String get title => 'Water in the dry spell';

	/// en: '{subject} may need watering during the dry weather.'
	String get body => '{subject} may need watering during the dry weather.';
}

// Path: suggestions.lawn.fertilize_spring
class Translations$suggestions$lawn$fertilize_spring$en {
	Translations$suggestions$lawn$fertilize_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring feed'
	String get title => 'Spring feed';

	/// en: 'Feed {subject} for the season — best by about {window_end_date}.'
	String get body => 'Feed {subject} for the season — best by about {window_end_date}.';
}

// Path: suggestions.lawn.fertilize_autumn
class Translations$suggestions$lawn$fertilize_autumn$en {
	Translations$suggestions$lawn$fertilize_autumn$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Autumn feed'
	String get title => 'Autumn feed';

	/// en: 'Give {subject} an autumn feed before winter — window open until ~{window_end_date}.'
	String get body => 'Give {subject} an autumn feed before winter — window open until ~{window_end_date}.';
}

// Path: suggestions.lawn.lime
class Translations$suggestions$lawn$lime$en {
	Translations$suggestions$lawn$lime$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lime the lawn'
	String get title => 'Lime the lawn';

	/// en: 'Apply lime to {subject} if the soil is acidic — by about {window_end_date}.'
	String get body => 'Apply lime to {subject} if the soil is acidic — by about {window_end_date}.';
}

// Path: suggestions.lawn.moss_control
class Translations$suggestions$lawn$moss_control$en {
	Translations$suggestions$lawn$moss_control$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Moss control'
	String get title => 'Moss control';

	/// en: 'Treat moss in {subject} — window open until ~{window_end_date}.'
	String get body => 'Treat moss in {subject} — window open until ~{window_end_date}.';
}

// Path: suggestions.lawn.weed_control
class Translations$suggestions$lawn$weed_control$en {
	Translations$suggestions$lawn$weed_control$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weed control'
	String get title => 'Weed control';

	/// en: 'Tackle weeds in {subject} — best by about {window_end_date}.'
	String get body => 'Tackle weeds in {subject} — best by about {window_end_date}.';
}

// Path: suggestions.lawn.overseed_spring
class Translations$suggestions$lawn$overseed_spring$en {
	Translations$suggestions$lawn$overseed_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overseed (spring)'
	String get title => 'Overseed (spring)';

	/// en: 'Overseed thin patches in {subject} — by about {window_end_date}.'
	String get body => 'Overseed thin patches in {subject} — by about {window_end_date}.';
}

// Path: suggestions.lawn.overseed_autumn
class Translations$suggestions$lawn$overseed_autumn$en {
	Translations$suggestions$lawn$overseed_autumn$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overseed (autumn)'
	String get title => 'Overseed (autumn)';

	/// en: 'Overseed {subject} in autumn — window open until ~{window_end_date}.'
	String get body => 'Overseed {subject} in autumn — window open until ~{window_end_date}.';
}

// Path: suggestions.lawn.scarify_spring
class Translations$suggestions$lawn$scarify_spring$en {
	Translations$suggestions$lawn$scarify_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scarify (spring)'
	String get title => 'Scarify (spring)';

	/// en: 'Scarify {subject} to clear thatch — by about {window_end_date}.'
	String get body => 'Scarify {subject} to clear thatch — by about {window_end_date}.';
}

// Path: suggestions.lawn.scarify_autumn
class Translations$suggestions$lawn$scarify_autumn$en {
	Translations$suggestions$lawn$scarify_autumn$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scarify (autumn)'
	String get title => 'Scarify (autumn)';

	/// en: 'Scarify {subject} in autumn — window open until ~{window_end_date}.'
	String get body => 'Scarify {subject} in autumn — window open until ~{window_end_date}.';
}

// Path: suggestions.lawn.aerate
class Translations$suggestions$lawn$aerate$en {
	Translations$suggestions$lawn$aerate$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Aerate'
	String get title => 'Aerate';

	/// en: 'Aerate {subject} to ease compaction — by about {window_end_date}.'
	String get body => 'Aerate {subject} to ease compaction — by about {window_end_date}.';
}

// Path: suggestions.lawn.roll
class Translations$suggestions$lawn$roll$en {
	Translations$suggestions$lawn$roll$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Roll the lawn'
	String get title => 'Roll the lawn';

	/// en: 'Roll {subject} after winter heave — window open until ~{window_end_date}.'
	String get body => 'Roll {subject} after winter heave — window open until ~{window_end_date}.';
}

// Path: suggestions.lawn.topdress
class Translations$suggestions$lawn$topdress$en {
	Translations$suggestions$lawn$topdress$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Top-dress'
	String get title => 'Top-dress';

	/// en: 'Top-dress {subject} to level and feed — by about {window_end_date}.'
	String get body => 'Top-dress {subject} to level and feed — by about {window_end_date}.';
}

// Path: suggestions.fruit_tree.fertilize_spring
class Translations$suggestions$fruit_tree$fertilize_spring$en {
	Translations$suggestions$fruit_tree$fertilize_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring feed'
	String get title => 'Spring feed';

	/// en: 'Feed your {subject} as growth starts — by about {window_end_date}.'
	String get body => 'Feed your {subject} as growth starts — by about {window_end_date}.';
}

// Path: suggestions.fruit_tree.prune_winter
class Translations$suggestions$fruit_tree$prune_winter$en {
	Translations$suggestions$fruit_tree$prune_winter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Winter pruning'
	String get title => 'Winter pruning';

	/// en: 'Prune {subject} while dormant — window open until ~{window_end_date}.'
	String get body => 'Prune {subject} while dormant — window open until ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.treat_dormant
class Translations$suggestions$fruit_tree$treat_dormant$en {
	Translations$suggestions$fruit_tree$treat_dormant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dormant spray'
	String get title => 'Dormant spray';

	/// en: 'Apply a dormant treatment to {subject} — by about {window_end_date}.'
	String get body => 'Apply a dormant treatment to {subject} — by about {window_end_date}.';
}

// Path: suggestions.fruit_tree.mulch
class Translations$suggestions$fruit_tree$mulch$en {
	Translations$suggestions$fruit_tree$mulch$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mulch'
	String get title => 'Mulch';

	/// en: 'Mulch around {subject} to hold moisture — by about {window_end_date}.'
	String get body => 'Mulch around {subject} to hold moisture — by about {window_end_date}.';
}

// Path: suggestions.fruit_tree.thin_fruit
class Translations$suggestions$fruit_tree$thin_fruit$en {
	Translations$suggestions$fruit_tree$thin_fruit$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Thin the fruit'
	String get title => 'Thin the fruit';

	/// en: 'Thin {subject}'s fruitlets for better size — window open until ~{window_end_date}.'
	String get body => 'Thin {subject}\'s fruitlets for better size — window open until ~{window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_spring
class Translations$suggestions$fruit_tree$graft_spring$en {
	Translations$suggestions$fruit_tree$graft_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring grafting'
	String get title => 'Spring grafting';

	/// en: 'Graft {subject} while the sap is rising — by about {window_end_date}.'
	String get body => 'Graft {subject} while the sap is rising — by about {window_end_date}.';
}

// Path: suggestions.fruit_tree.graft_budding
class Translations$suggestions$fruit_tree$graft_budding$en {
	Translations$suggestions$fruit_tree$graft_budding$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Summer budding'
	String get title => 'Summer budding';

	/// en: 'Bud-graft {subject} in late summer — window open until ~{window_end_date}.'
	String get body => 'Bud-graft {subject} in late summer — window open until ~{window_end_date}.';
}

// Path: suggestions.berries.prune_winter
class Translations$suggestions$berries$prune_winter$en {
	Translations$suggestions$berries$prune_winter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Winter pruning'
	String get title => 'Winter pruning';

	/// en: 'Prune {subject} while dormant — by about {window_end_date}.'
	String get body => 'Prune {subject} while dormant — by about {window_end_date}.';
}

// Path: suggestions.berries.fertilize_spring
class Translations$suggestions$berries$fertilize_spring$en {
	Translations$suggestions$berries$fertilize_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring feed'
	String get title => 'Spring feed';

	/// en: 'Feed {subject} as growth starts — by about {window_end_date}.'
	String get body => 'Feed {subject} as growth starts — by about {window_end_date}.';
}

// Path: suggestions.berries.mulch
class Translations$suggestions$berries$mulch$en {
	Translations$suggestions$berries$mulch$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mulch'
	String get title => 'Mulch';

	/// en: 'Mulch {subject} to keep roots cool and moist — by about {window_end_date}.'
	String get body => 'Mulch {subject} to keep roots cool and moist — by about {window_end_date}.';
}

// Path: suggestions.berries.treat_dormant
class Translations$suggestions$berries$treat_dormant$en {
	Translations$suggestions$berries$treat_dormant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dormant spray'
	String get title => 'Dormant spray';

	/// en: 'Apply a dormant treatment to {subject} — by about {window_end_date}.'
	String get body => 'Apply a dormant treatment to {subject} — by about {window_end_date}.';
}

// Path: suggestions.vegetable.start_seedlings
class Translations$suggestions$vegetable$start_seedlings$en {
	Translations$suggestions$vegetable$start_seedlings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start seedlings'
	String get title => 'Start seedlings';

	/// en: 'Sow {subject} indoors to get ahead for planting out — by about {window_end_date}.'
	String get body => 'Sow {subject} indoors to get ahead for planting out — by about {window_end_date}.';
}

// Path: suggestions.vegetable.prick_out
class Translations$suggestions$vegetable$prick_out$en {
	Translations$suggestions$vegetable$prick_out$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prick out'
	String get title => 'Prick out';

	/// en: 'You started {subject} {days_since} days ago — prick the seedlings into pots.'
	String get body => 'You started {subject} {days_since} days ago — prick the seedlings into pots.';
}

// Path: suggestions.vegetable.harden_off
class Translations$suggestions$vegetable$harden_off$en {
	Translations$suggestions$vegetable$harden_off$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Harden off'
	String get title => 'Harden off';

	/// en: 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.'
	String get body => 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.';
}

// Path: suggestions.vegetable.plant_out
class Translations$suggestions$vegetable$plant_out$en {
	Translations$suggestions$vegetable$plant_out$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plant out'
	String get title => 'Plant out';

	/// en: 'Plant {subject} outside once frost has passed — around {frost_date}.'
	String get body => 'Plant {subject} outside once frost has passed — around {frost_date}.';
}

// Path: suggestions.vegetable.transplant
class Translations$suggestions$vegetable$transplant$en {
	Translations$suggestions$vegetable$transplant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transplant'
	String get title => 'Transplant';

	/// en: 'Move {subject} to its final spot after frost — around {frost_date}.'
	String get body => 'Move {subject} to its final spot after frost — around {frost_date}.';
}

// Path: suggestions.vegetable.sow_direct
class Translations$suggestions$vegetable$sow_direct$en {
	Translations$suggestions$vegetable$sow_direct$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Direct sow'
	String get title => 'Direct sow';

	/// en: 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.'
	String get body => 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.';
}

// Path: suggestions.vegetable.fertilize_season
class Translations$suggestions$vegetable$fertilize_season$en {
	Translations$suggestions$vegetable$fertilize_season$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feed'
	String get title => 'Feed';

	/// en: 'Give {subject} a feed during the growing season.'
	String get body => 'Give {subject} a feed during the growing season.';
}

// Path: suggestions.vegetable.treat_window
class Translations$suggestions$vegetable$treat_window$en {
	Translations$suggestions$vegetable$treat_window$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Treat'
	String get title => 'Treat';

	/// en: 'Check {subject} and treat if needed — dry weather is best.'
	String get body => 'Check {subject} and treat if needed — dry weather is best.';
}

// Path: suggestions.herbs.start_seedlings
class Translations$suggestions$herbs$start_seedlings$en {
	Translations$suggestions$herbs$start_seedlings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start seedlings'
	String get title => 'Start seedlings';

	/// en: 'Sow {subject} indoors for a head start — by about {window_end_date}.'
	String get body => 'Sow {subject} indoors for a head start — by about {window_end_date}.';
}

// Path: suggestions.herbs.sow_direct
class Translations$suggestions$herbs$sow_direct$en {
	Translations$suggestions$herbs$sow_direct$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Direct sow'
	String get title => 'Direct sow';

	/// en: 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.'
	String get body => 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.';
}

// Path: suggestions.herbs.plant_out
class Translations$suggestions$herbs$plant_out$en {
	Translations$suggestions$herbs$plant_out$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Plant out'
	String get title => 'Plant out';

	/// en: 'Plant {subject} outside once frost has passed — around {frost_date}.'
	String get body => 'Plant {subject} outside once frost has passed — around {frost_date}.';
}

// Path: suggestions.tomato.start_seedlings
class Translations$suggestions$tomato$start_seedlings$en {
	Translations$suggestions$tomato$start_seedlings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start seedlings'
	String get title => 'Start seedlings';

	/// en: 'Sow {subject} indoors for a head start — by about {window_end_date}.'
	String get body => 'Sow {subject} indoors for a head start — by about {window_end_date}.';
}

// Path: suggestions.tomato.prick_out
class Translations$suggestions$tomato$prick_out$en {
	Translations$suggestions$tomato$prick_out$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prick out'
	String get title => 'Prick out';

	/// en: 'You sowed {subject} {days_since} days ago — prick the seedlings into pots.'
	String get body => 'You sowed {subject} {days_since} days ago — prick the seedlings into pots.';
}

// Path: suggestions.tomato.harden_off
class Translations$suggestions$tomato$harden_off$en {
	Translations$suggestions$tomato$harden_off$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Harden off'
	String get title => 'Harden off';

	/// en: 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.'
	String get body => 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.';
}

// Path: suggestions.tomato.transplant
class Translations$suggestions$tomato$transplant$en {
	Translations$suggestions$tomato$transplant$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transplant'
	String get title => 'Transplant';

	/// en: '{subject} has grown for {days_since} days — move it to its final position.'
	String get body => '{subject} has grown for {days_since} days — move it to its final position.';
}

// Path: suggestions.tomato.stake
class Translations$suggestions$tomato$stake$en {
	Translations$suggestions$tomato$stake$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stake'
	String get title => 'Stake';

	/// en: '{subject} is {days_since} days on — add a stake or support.'
	String get body => '{subject} is {days_since} days on — add a stake or support.';
}

// Path: suggestions.shrub.prune_spring
class Translations$suggestions$shrub$prune_spring$en {
	Translations$suggestions$shrub$prune_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring pruning'
	String get title => 'Spring pruning';

	/// en: 'Prune {subject} as needed — by about {window_end_date}.'
	String get body => 'Prune {subject} as needed — by about {window_end_date}.';
}

// Path: suggestions.shrub.overwinter
class Translations$suggestions$shrub$overwinter$en {
	Translations$suggestions$shrub$overwinter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Winter protection'
	String get title => 'Winter protection';

	/// en: 'Protect {subject} before the first hard frost — by about {window_end_date}.'
	String get body => 'Protect {subject} before the first hard frost — by about {window_end_date}.';
}

// Path: suggestions.hedge.prune_early_summer
class Translations$suggestions$hedge$prune_early_summer$en {
	Translations$suggestions$hedge$prune_early_summer$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Early-summer trim'
	String get title => 'Early-summer trim';

	/// en: 'Trim {subject} for shape — window open until ~{window_end_date}.'
	String get body => 'Trim {subject} for shape — window open until ~{window_end_date}.';
}

// Path: suggestions.hedge.prune_late_summer
class Translations$suggestions$hedge$prune_late_summer$en {
	Translations$suggestions$hedge$prune_late_summer$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Late-summer trim'
	String get title => 'Late-summer trim';

	/// en: 'Give {subject} a final trim before autumn — by about {window_end_date}.'
	String get body => 'Give {subject} a final trim before autumn — by about {window_end_date}.';
}

// Path: suggestions.conifer.prune
class Translations$suggestions$conifer$prune$en {
	Translations$suggestions$conifer$prune$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Trim'
	String get title => 'Trim';

	/// en: 'Trim {subject} lightly into new growth — by about {window_end_date}.'
	String get body => 'Trim {subject} lightly into new growth — by about {window_end_date}.';
}

// Path: suggestions.houseplant.repot
class Translations$suggestions$houseplant$repot$en {
	Translations$suggestions$houseplant$repot$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Repot'
	String get title => 'Repot';

	/// en: 'Repot {subject} as growth resumes — window open until ~{window_end_date}.'
	String get body => 'Repot {subject} as growth resumes — window open until ~{window_end_date}.';
}

// Path: suggestions.houseplant.fertilize_season
class Translations$suggestions$houseplant$fertilize_season$en {
	Translations$suggestions$houseplant$fertilize_season$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feed'
	String get title => 'Feed';

	/// en: 'Feed {subject} during the active growing season.'
	String get body => 'Feed {subject} during the active growing season.';
}

// Path: suggestions.houseplant.overwinter
class Translations$suggestions$houseplant$overwinter$en {
	Translations$suggestions$houseplant$overwinter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bring indoors'
	String get title => 'Bring indoors';

	/// en: 'Move {subject} indoors before the first frost — by about {window_end_date}.'
	String get body => 'Move {subject} indoors before the first frost — by about {window_end_date}.';
}

// Path: suggestions.blueberry.prune
class Translations$suggestions$blueberry$prune$en {
	Translations$suggestions$blueberry$prune$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pruning'
	String get title => 'Pruning';

	/// en: 'Prune {subject} while dormant — by about {window_end_date}.'
	String get body => 'Prune {subject} while dormant — by about {window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_spring
class Translations$suggestions$cherry_laurel$prune_late_spring$en {
	Translations$suggestions$cherry_laurel$prune_late_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Late-spring trim'
	String get title => 'Late-spring trim';

	/// en: 'Trim {subject} after the first flush — window open until ~{window_end_date}.'
	String get body => 'Trim {subject} after the first flush — window open until ~{window_end_date}.';
}

// Path: suggestions.cherry_laurel.prune_late_summer
class Translations$suggestions$cherry_laurel$prune_late_summer$en {
	Translations$suggestions$cherry_laurel$prune_late_summer$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Late-summer trim'
	String get title => 'Late-summer trim';

	/// en: 'Give {subject} a second trim — by about {window_end_date}.'
	String get body => 'Give {subject} a second trim — by about {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_old_wood
class Translations$suggestions$hydrangea$prune_old_wood$en {
	Translations$suggestions$hydrangea$prune_old_wood$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prune (old wood)'
	String get title => 'Prune (old wood)';

	/// en: 'Deadhead and tidy old-wood {subject} after flowering — by about {window_end_date}.'
	String get body => 'Deadhead and tidy old-wood {subject} after flowering — by about {window_end_date}.';
}

// Path: suggestions.hydrangea.prune_new_wood
class Translations$suggestions$hydrangea$prune_new_wood$en {
	Translations$suggestions$hydrangea$prune_new_wood$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prune (new wood)'
	String get title => 'Prune (new wood)';

	/// en: 'Cut back new-wood {subject} in late winter — by about {window_end_date}.'
	String get body => 'Cut back new-wood {subject} in late winter — by about {window_end_date}.';
}

// Path: suggestions.peach.prune_spring
class Translations$suggestions$peach$prune_spring$en {
	Translations$suggestions$peach$prune_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring pruning'
	String get title => 'Spring pruning';

	/// en: 'Prune {subject} as the buds swell to limit leaf curl — by about {window_end_date}.'
	String get body => 'Prune {subject} as the buds swell to limit leaf curl — by about {window_end_date}.';
}

// Path: suggestions.raspberry.prune_late_winter
class Translations$suggestions$raspberry$prune_late_winter$en {
	Translations$suggestions$raspberry$prune_late_winter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Late-winter pruning'
	String get title => 'Late-winter pruning';

	/// en: 'Prune {subject} canes before growth starts — by about {window_end_date}.'
	String get body => 'Prune {subject} canes before growth starts — by about {window_end_date}.';
}

// Path: suggestions.raspberry.prune_after_harvest
class Translations$suggestions$raspberry$prune_after_harvest$en {
	Translations$suggestions$raspberry$prune_after_harvest$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'After-harvest pruning'
	String get title => 'After-harvest pruning';

	/// en: '{subject} fruited {days_since} days ago — cut out the old canes.'
	String get body => '{subject} fruited {days_since} days ago — cut out the old canes.';
}

// Path: suggestions.rose.prune_spring
class Translations$suggestions$rose$prune_spring$en {
	Translations$suggestions$rose$prune_spring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Spring pruning'
	String get title => 'Spring pruning';

	/// en: 'Prune {subject} as the buds break — by about {window_end_date}.'
	String get body => 'Prune {subject} as the buds break — by about {window_end_date}.';
}

// Path: suggestions.rose.overwinter
class Translations$suggestions$rose$overwinter$en {
	Translations$suggestions$rose$overwinter$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Winter protection'
	String get title => 'Winter protection';

	/// en: 'Mound or wrap {subject} before hard frost — by about {window_end_date}.'
	String get body => 'Mound or wrap {subject} before hard frost — by about {window_end_date}.';
}

// Path: suggestions.cucumber.sow_direct
class Translations$suggestions$cucumber$sow_direct$en {
	Translations$suggestions$cucumber$sow_direct$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Direct sow'
	String get title => 'Direct sow';

	/// en: 'Sow {subject} outdoors once it is warm and frost-free — around {frost_date}.'
	String get body => 'Sow {subject} outdoors once it is warm and frost-free — around {frost_date}.';
}

// Path: suggestions.zucchini.sow_direct
class Translations$suggestions$zucchini$sow_direct$en {
	Translations$suggestions$zucchini$sow_direct$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Direct sow'
	String get title => 'Direct sow';

	/// en: 'Sow {subject} outdoors after frost — around {frost_date}.'
	String get body => 'Sow {subject} outdoors after frost — around {frost_date}.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'splash.tagline' => 'Your garden journal 🌿',
			'nav.home' => 'Home',
			'nav.journal' => 'Journal',
			'nav.areas' => 'Garden',
			'nav.tasks' => 'Tasks',
			'home.greeting' => 'Good day 🌿',
			'home.today' => 'Today',
			'home.recent' => 'Recent',
			'home.no_tasks_today' => 'No tasks planned for today.',
			'home.no_recent' => 'No completed tasks yet.',
			'home.overdue_banner' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 overdue task', other: '${n} overdue tasks', ), 
			'common.today' => 'Today',
			'common.yesterday' => 'yesterday',
			'common.load_error' => 'Couldn\'t load data.',
			'swipe.complete' => 'Done',
			'swipe.postpone' => '+1 day',
			'swipe.revert' => 'Reopen',
			'swipe.edit' => 'Edit',
			'swipe.move' => 'Move',
			'swipe.delete' => 'Delete',
			'notifications.today' => 'Today',
			'notifications.tomorrow' => 'Tomorrow',
			'notif_priming.title' => 'Let me remind you in time?',
			'notif_priming.why' => 'So a task doesn\'t slip by — the reminder arrives exactly when you set it.',
			'notif_priming.benefit_reminders' => 'Task reminders — e.g. "1 day before at 18:00".',
			'notif_priming.benefit_weather' => 'Smart weather hint — "dry tomorrow, a good time". (optional)',
			'notif_priming.benefit_nearby' => 'Neighbourhood hints — what others nearby are doing. (V2, optional)',
			'notif_priming.privacy' => 'You can turn each type on or off separately, set quiet hours and cap frequency. No spam.',
			'notif_priming.enable' => 'Turn on notifications',
			'notif_priming.later' => 'Maybe later',
			'notif_settings.title' => 'Notifications',
			'notif_settings.load_error' => 'Couldn\'t load settings.',
			'notif_settings.section_types' => 'Notification types',
			'notif_settings.type_reminders' => 'Task reminders',
			'notif_settings.type_reminders_sub' => 'local · works offline',
			'notif_settings.type_weather' => 'Smart hints (weather)',
			'notif_settings.type_weather_sub' => '"dry tomorrow — a good time"',
			'notif_settings.type_community' => 'Nearby hints',
			'notif_settings.type_community_sub' => 'what others nearby are doing',
			'notif_settings.section_default_offset' => 'Default reminder offset',
			'notif_settings.default_offset_hint' => 'Prefills new tasks; you can always change it.',
			'notif_settings.section_quiet' => 'So you\'re not overwhelmed',
			'notif_settings.quiet_hours' => 'Quiet hours',
			'notif_settings.quiet_hours_sub' => ({required Object range}) => '${range}, no notifications',
			'notif_settings.frequency_cap' => 'At most 1 hint per day',
			'notif_settings.frequency_cap_sub' => 'weather and nearby combined into one summary',
			'notif_settings.section_more' => 'More',
			'notif_settings.preview' => 'Notification preview',
			'notif_settings.preview_sub' => 'how they look on the lock screen',
			'notif_settings.system_permission' => 'System permission',
			'notif_settings.system_permission_on' => 'device: allowed',
			'notif_settings.system_permission_off' => 'exact reminders not allowed — tap for settings',
			'notif_settings.hints_perm_denied' => 'Notifications are disabled, so hints can\'t be turned on.',
			'notif_preview.title' => 'Notification appearance',
			'notif_preview.date' => 'Tuesday, 1 June',
			'notif_preview.rem_now' => 'now',
			'notif_preview.rem_title' => '⏰ Foliar spraying · 07:00',
			'notif_preview.rem_body' => 'Hedge + lawn · the morning is dry — a good time.',
			'notif_preview.rem_tag' => 'task reminder',
			'notif_preview.wx_title' => 'Tomorrow morning will be dry ☀️',
			'notif_preview.wx_body' => 'A good time for foliar spraying of cherry laurels.',
			'notif_preview.wx_tag' => 'smart hint · weather',
			'notif_preview.com_yesterday' => 'yesterday',
			'notif_preview.com_title' => 'Your area',
			'notif_preview.com_body' => '68% of gardeners near you fertilised their lawn for the first time this week.',
			'notif_preview.com_tag' => 'nearby hint · V2',
			'notif_preview.footer' => 'Tapping a notification opens the right screen (task · hint · nearby).',
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
			'auth.value_prop' => 'Save your garden journal and don\'t lose your history when you change phones.',
			'auth.continue_apple' => 'Continue with Apple',
			'auth.continue_google' => 'Continue with Google',
			'auth.continue_email' => 'Continue with email',
			'auth.guest' => 'Try without an account',
			'auth.legal' => 'We\'ll send a confirmation code by email (no password). Continuing means you agree to the terms and privacy policy.',
			'auth.guest_warning' => 'Without an account, all your data is lost if you remove the app or change device.',
			'auth.google_error' => 'Google sign-in failed. Please try again.',
			'auth.coming_soon' => 'Coming soon.',
			'auth.privacy_link' => 'Privacy policy',
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
			'email_login.err_email_domain' => 'We can\'t find that email\'s domain. Check the address.',
			'email_login.did_you_mean' => ({required Object suggestion}) => 'Did you mean ${suggestion}?',
			'email_login.resend_in' => ({required Object seconds}) => 'Send a new code (${seconds} s)',
			'location.title' => 'Where do you garden?',
			'location.why' => 'We need your location for the local weather forecast and (later) to show you what gardeners in a similar climate are doing.',
			'location.use_gps' => 'Use my location',
			'location.enter_place' => 'Enter a place',
			'location.or' => 'or',
			'location.gps_sub' => 'Automatically via device GPS',
			'location.place_hint' => 'Village, town or address (e.g. Šentjur)',
			'location.place_note' => 'A village or town is enough — no exact address needed.',
			'location.search' => 'Search',
			'location.privacy' => 'We never store your exact location. We only keep an approximate area (a wider region of a few km), which we never reveal to others.',
			'location.kContinue' => 'Continue',
			'location.set_gps' => 'Location set.',
			'location.set_place' => ({required Object name}) => 'Location: ${name}',
			'location.err_denied' => 'Location access denied. Enter a place or grant permission in system settings.',
			'location.err_disabled' => 'Location services are off. Turn them on or enter a place.',
			'location.err_unavailable' => 'Couldn\'t determine your location. Try again or enter a place.',
			'location.err_search' => 'Search failed. Check your connection and try again.',
			'location.no_results' => 'No matches for that place.',
			'location.screen_title' => 'Garden location',
			'location.status_set' => 'Location is set',
			'location.status_set_at' => ({required Object name}) => 'Location is set · ${name}',
			'location.status_unset' => 'Location not set yet',
			'location.clear' => 'Remove location',
			'location.clear_confirm_title' => 'Remove location?',
			'location.clear_confirm_body' => 'Weather will use the default region until you set a new location.',
			'location.clear_confirm_yes' => 'Remove',
			'location.clear_confirm_cancel' => 'Cancel',
			'location.cleared' => 'Location removed',
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
			'entry.rem_custom' => 'Custom…',
			'entry.rem_unit_min' => 'min',
			'entry.rem_unit_hour' => 'hrs',
			'entry.rem_unit_day' => 'days',
			'entry.rem_custom_label' => 'How long before?',
			'entry.rem_before' => 'before',
			'entry.rem_at' => ({required Object t}) => 'at ${t}',
			'entry.rem_choose_time' => 'At time',
			'entry.rem_time_note' => 'The time applies to day-based offsets (e.g. "1 day before at 18:00").',
			'entry.rem_perm_denied' => 'Notifications are disabled, so a reminder can\'t be added.',
			'entry.rem_exact_title' => 'Allow exact reminders',
			'entry.rem_exact_body' => 'To fire at the exact time, Tendask needs the "Alarms & reminders" permission. Enable it in settings, then add the reminder again.',
			'entry.rem_exact_open' => 'Open settings',
			'entry.rem_added' => 'already added',
			'plant_edit.title_edit' => 'Edit plant',
			'plant_edit.species' => 'Species',
			'plant_edit.alias' => 'Personal name (optional)',
			'plant_edit.alias_hint' => 'e.g. “old apple by the fence”',
			'plant_edit.alias_note' => 'Only you see it; shown instead of the default name.',
			'plant_edit.location_label' => 'Area',
			'plant_edit.delete' => 'Remove plant from garden',
			'plant_edit.delete_note' => 'Task history stays in the journal.',
			'plant_edit.save' => 'Save',
			'plant_detail.not_found' => 'Plant not found.',
			'plant_detail.history_title' => 'Task history',
			'plant_detail.history_empty' => 'No tasks for this plant yet.',
			'plant_detail.move' => 'move',
			'plant_detail.assign_area' => 'Assign area',
			'area_pick.move_title' => ({required Object name}) => 'Move “${name}”',
			'area_pick.choose_title' => 'Choose area',
			'area_pick.note' => 'A plant lives in one area (or none). Its task history stays.',
			'area_pick.none' => 'No area',
			'area_pick.current' => 'current',
			'area_pick.new_area' => 'New area',
			'area_pick.duplicate' => 'This plant is already in the selected area.',
			'areas.title' => 'Garden',
			'areas.subtitle' => 'plants and lawns',
			'areas.unassigned' => 'No area',
			'areas.last_prefix' => 'last:',
			'areas.type_garden' => 'Garden',
			'areas.type_lawn' => 'Lawn',
			'areas.type_hedge' => 'Hedge',
			'areas.type_bed' => 'Bed',
			'areas.type_tree' => 'Fruit tree',
			'areas.type_ornamental' => 'Ornamental',
			'areas.type_other' => 'Other',
			'areas.default_garden_name' => 'Garden',
			'areas.history_title' => 'Task history',
			'areas.history_empty' => 'No tasks in this area yet.',
			'areas.plants_section' => 'Plants',
			'areas.add_plant_here' => ({required Object area}) => 'Add plant to ${area}',
			'areas.delete_reparent_note' => 'Plants in this area move to “No area” (they are not deleted).',
			'areas.new_area_inline' => 'New area',
			'areas.empty_title' => 'Your garden is empty',
			'areas.empty_body' => 'Add the plants you have. Areas (beds, lawns) are optional.',
			'areas.empty_cta_plant' => 'Add plants',
			'areas.empty_cta_area' => 'Add area',
			'areas.action_edit' => 'Edit',
			'areas.action_delete' => 'Delete',
			'areas.delete_confirm_title' => 'Delete area?',
			'areas.delete_confirm_body' => 'Tasks remain but lose their link to this area.',
			'areas.form_title_new' => 'New area',
			'areas.form_title_edit' => 'Edit area',
			'areas.form_name' => 'Name',
			'areas.form_name_hint' => 'e.g. Raised bed 1',
			'areas.form_type' => 'Type',
			'areas.form_save' => 'Save area',
			'areas.err_name' => 'Enter an area name.',
			'plants.picker_title' => 'Select plant',
			'plants.search_hint' => 'Search plant…',
			'plants.cat_all' => 'All',
			'plants.cat_fruit_tree' => 'Fruit trees',
			'plants.cat_berries' => 'Berries',
			'plants.cat_vegetable' => 'Vegetables',
			'plants.cat_herbs' => 'Herbs',
			'plants.cat_ornamental' => 'Ornamental',
			'plants.cat_houseplant' => 'Houseplants',
			'plants.cat_lawn' => 'Lawn',
			'plants.from_catalog' => 'From catalog',
			'plants.not_found' => 'Can\'t find it?',
			'plants.custom_add' => ({required Object q}) => '+ Add custom: “${q}”',
			'plants.custom_private' => 'A custom entry is private and not shared with the community.',
			'plants.add_title' => 'Add plants',
			'plants.frequent' => 'Frequent',
			'plants.undo' => 'Undo',
			'plants.done' => 'Done',
			'plants.add_to_label' => 'Add to',
			'plants.choose_area' => 'choose',
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
			'settings.section_suggestions' => 'Suggestions',
			'settings.suggestions_history_sub' => 'What was suggested and how you responded',
			'settings.section_garden' => 'Garden',
			'settings.supplies' => '📦 Supplies',
			'settings.supplies_sub' => 'urea, algae, fertilizers, gear',
			'settings.section_account' => 'Account & data',
			'settings.export_data' => 'Export data (GDPR)',
			'settings.logout' => 'Sign out',
			'settings.logout_confirm_title' => 'Sign out?',
			'settings.logout_confirm_body' => 'Signs you out and clears local data from this device. Synced data stays in the cloud and returns when you sign in again with the same account.',
			'settings.logout_cancel' => 'Cancel',
			'settings.logout_offline' => 'Can\'t sign out while offline — your data isn\'t saved to the cloud yet. Try again when you\'re connected.',
			'settings.export_share_text' => 'Tendask data export',
			'settings.export_error' => 'Export failed. Please try again.',
			'settings.delete_account' => 'Delete account and all data',
			'settings.delete_account_confirm_title' => 'Delete account?',
			'settings.delete_account_confirm_body' => 'Permanently deletes your account and all data (tasks, areas, plants, notes) — both in the cloud and on this device. This cannot be undone.',
			'settings.delete_account_confirm' => 'Delete account',
			'settings.delete_account_error' => 'Deletion failed. Try again when you\'re connected.',
			'settings.delete_data' => 'Delete all data on this device',
			'settings.delete_data_confirm_title' => 'Delete all data?',
			'settings.delete_data_confirm_body' => 'Permanently deletes all data on this device (tasks, areas, plants, notes). This cannot be undone.',
			'settings.delete_data_confirm' => 'Delete',
			'settings.section_about' => 'About',
			'settings.privacy_policy' => 'Privacy policy',
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
			'weather.detail_none' => 'No weather snapshot (was offline at the time).',
			'weather.home_unavailable' => 'Weather is currently unavailable.',
			'weather.home_retry' => 'Tap to retry',
			'weather.loading' => 'Loading weather…',
			'weather.updated_at' => ({required Object time}) => 'Updated ${time}',
			'weather.m_humidity' => 'Humidity',
			'weather.m_wind' => 'Wind',
			'weather.m_precipitation' => 'Precipitation',
			'weather.m_soil_temp' => 'Soil temp.',
			'weather.m_et0' => 'ET₀',
			'weather.m_rain48h' => 'Rain 48 h',
			'weather.m_no_rain' => 'no rain',
			'suggestions.actions.plan' => 'Plan',
			'suggestions.actions.dismiss' => 'Skip',
			'suggestions.actions.already_done' => 'Already done',
			'suggestions.actions.never' => 'Don\'t suggest this again',
			'suggestions.actions.remove_subject' => 'I no longer have this',
			'suggestions.toast.planned' => 'Added to your tasks',
			'suggestions.toast.logged' => 'Logged as done',
			'suggestions.disclaimer' => 'Suggestions are general guidance — you know your garden best.',
			'suggestions.done_sheet.title' => 'When did you do it?',
			'suggestions.done_sheet.today' => 'Today',
			'suggestions.done_sheet.yesterday' => 'Yesterday',
			'suggestions.done_sheet.pick' => 'Pick a date…',
			'suggestions.remove.title' => 'Remove this?',
			'suggestions.remove.body' => 'This removes {subject} from your garden and stops its suggestions. Your past records stay.',
			'suggestions.remove.confirm' => 'Remove',
			'suggestions.history_status.planned' => 'Planned',
			'suggestions.history_status.logged' => 'Logged',
			'suggestions.history_status.dismissed' => 'Dismissed',
			'suggestions.history_status.muted' => 'Muted',
			'suggestions.history_status.missed' => 'Missed',
			'suggestions.band_title' => 'Suggestions for you',
			'suggestions.past_link' => 'History',
			'suggestions.past_title' => 'Past suggestions',
			'suggestions.past_intro' => 'What Tendask suggested and how you responded.',
			'suggestions.past_empty' => 'No history yet. When you respond to a suggestion — plan it, skip it or log it as done — it appears here.',
			'suggestions.past_retention' => 'Suggestions older than a year are cleared automatically.',
			'suggestions.cadence.overdue.title' => '{task} is due',
			'suggestions.cadence.overdue.body' => '{subject} is about {days_overdue} days past the usual ~{cadence_days}-day rhythm.',
			'suggestions.history.anniversary.title' => '{task} — a year ago',
			'suggestions.history.anniversary.body' => 'Last year around {last_year_date} — {task} for {subject}. Worth repeating?',
			'suggestions.weather.window_open.title' => '{task}: good window',
			'suggestions.weather.window_open.body' => 'A dry spell is on the way for {subject} — a good time to do it.',
			'suggestions.community.most_started.title' => '{task} nearby',
			'suggestions.community.most_started.body' => 'About {percent}% of gardeners near you have started this so far this season.',
			'suggestions.lawn.mow_due.title' => 'Mowing due',
			'suggestions.lawn.mow_due.body' => '{subject} is ready for a mow.',
			'suggestions.lawn.water_drought.title' => 'Water in the dry spell',
			'suggestions.lawn.water_drought.body' => '{subject} may need watering during the dry weather.',
			'suggestions.lawn.fertilize_spring.title' => 'Spring feed',
			'suggestions.lawn.fertilize_spring.body' => 'Feed {subject} for the season — best by about {window_end_date}.',
			'suggestions.lawn.fertilize_autumn.title' => 'Autumn feed',
			'suggestions.lawn.fertilize_autumn.body' => 'Give {subject} an autumn feed before winter — window open until ~{window_end_date}.',
			'suggestions.lawn.lime.title' => 'Lime the lawn',
			'suggestions.lawn.lime.body' => 'Apply lime to {subject} if the soil is acidic — by about {window_end_date}.',
			'suggestions.lawn.moss_control.title' => 'Moss control',
			'suggestions.lawn.moss_control.body' => 'Treat moss in {subject} — window open until ~{window_end_date}.',
			'suggestions.lawn.weed_control.title' => 'Weed control',
			'suggestions.lawn.weed_control.body' => 'Tackle weeds in {subject} — best by about {window_end_date}.',
			'suggestions.lawn.overseed_spring.title' => 'Overseed (spring)',
			'suggestions.lawn.overseed_spring.body' => 'Overseed thin patches in {subject} — by about {window_end_date}.',
			'suggestions.lawn.overseed_autumn.title' => 'Overseed (autumn)',
			'suggestions.lawn.overseed_autumn.body' => 'Overseed {subject} in autumn — window open until ~{window_end_date}.',
			'suggestions.lawn.scarify_spring.title' => 'Scarify (spring)',
			'suggestions.lawn.scarify_spring.body' => 'Scarify {subject} to clear thatch — by about {window_end_date}.',
			'suggestions.lawn.scarify_autumn.title' => 'Scarify (autumn)',
			'suggestions.lawn.scarify_autumn.body' => 'Scarify {subject} in autumn — window open until ~{window_end_date}.',
			'suggestions.lawn.aerate.title' => 'Aerate',
			'suggestions.lawn.aerate.body' => 'Aerate {subject} to ease compaction — by about {window_end_date}.',
			'suggestions.lawn.roll.title' => 'Roll the lawn',
			'suggestions.lawn.roll.body' => 'Roll {subject} after winter heave — window open until ~{window_end_date}.',
			'suggestions.lawn.topdress.title' => 'Top-dress',
			'suggestions.lawn.topdress.body' => 'Top-dress {subject} to level and feed — by about {window_end_date}.',
			'suggestions.fruit_tree.fertilize_spring.title' => 'Spring feed',
			'suggestions.fruit_tree.fertilize_spring.body' => 'Feed your {subject} as growth starts — by about {window_end_date}.',
			'suggestions.fruit_tree.prune_winter.title' => 'Winter pruning',
			'suggestions.fruit_tree.prune_winter.body' => 'Prune {subject} while dormant — window open until ~{window_end_date}.',
			'suggestions.fruit_tree.treat_dormant.title' => 'Dormant spray',
			'suggestions.fruit_tree.treat_dormant.body' => 'Apply a dormant treatment to {subject} — by about {window_end_date}.',
			'suggestions.fruit_tree.mulch.title' => 'Mulch',
			'suggestions.fruit_tree.mulch.body' => 'Mulch around {subject} to hold moisture — by about {window_end_date}.',
			'suggestions.fruit_tree.thin_fruit.title' => 'Thin the fruit',
			'suggestions.fruit_tree.thin_fruit.body' => 'Thin {subject}\'s fruitlets for better size — window open until ~{window_end_date}.',
			'suggestions.fruit_tree.graft_spring.title' => 'Spring grafting',
			'suggestions.fruit_tree.graft_spring.body' => 'Graft {subject} while the sap is rising — by about {window_end_date}.',
			'suggestions.fruit_tree.graft_budding.title' => 'Summer budding',
			'suggestions.fruit_tree.graft_budding.body' => 'Bud-graft {subject} in late summer — window open until ~{window_end_date}.',
			'suggestions.berries.prune_winter.title' => 'Winter pruning',
			'suggestions.berries.prune_winter.body' => 'Prune {subject} while dormant — by about {window_end_date}.',
			'suggestions.berries.fertilize_spring.title' => 'Spring feed',
			'suggestions.berries.fertilize_spring.body' => 'Feed {subject} as growth starts — by about {window_end_date}.',
			_ => null,
		} ?? switch (path) {
			'suggestions.berries.mulch.title' => 'Mulch',
			'suggestions.berries.mulch.body' => 'Mulch {subject} to keep roots cool and moist — by about {window_end_date}.',
			'suggestions.berries.treat_dormant.title' => 'Dormant spray',
			'suggestions.berries.treat_dormant.body' => 'Apply a dormant treatment to {subject} — by about {window_end_date}.',
			'suggestions.vegetable.start_seedlings.title' => 'Start seedlings',
			'suggestions.vegetable.start_seedlings.body' => 'Sow {subject} indoors to get ahead for planting out — by about {window_end_date}.',
			'suggestions.vegetable.prick_out.title' => 'Prick out',
			'suggestions.vegetable.prick_out.body' => 'You started {subject} {days_since} days ago — prick the seedlings into pots.',
			'suggestions.vegetable.harden_off.title' => 'Harden off',
			'suggestions.vegetable.harden_off.body' => 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.',
			'suggestions.vegetable.plant_out.title' => 'Plant out',
			'suggestions.vegetable.plant_out.body' => 'Plant {subject} outside once frost has passed — around {frost_date}.',
			'suggestions.vegetable.transplant.title' => 'Transplant',
			'suggestions.vegetable.transplant.body' => 'Move {subject} to its final spot after frost — around {frost_date}.',
			'suggestions.vegetable.sow_direct.title' => 'Direct sow',
			'suggestions.vegetable.sow_direct.body' => 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.',
			'suggestions.vegetable.fertilize_season.title' => 'Feed',
			'suggestions.vegetable.fertilize_season.body' => 'Give {subject} a feed during the growing season.',
			'suggestions.vegetable.treat_window.title' => 'Treat',
			'suggestions.vegetable.treat_window.body' => 'Check {subject} and treat if needed — dry weather is best.',
			'suggestions.herbs.start_seedlings.title' => 'Start seedlings',
			'suggestions.herbs.start_seedlings.body' => 'Sow {subject} indoors for a head start — by about {window_end_date}.',
			'suggestions.herbs.sow_direct.title' => 'Direct sow',
			'suggestions.herbs.sow_direct.body' => 'Sow {subject} directly outdoors once it turns mild — window open until ~{window_end_date}.',
			'suggestions.herbs.plant_out.title' => 'Plant out',
			'suggestions.herbs.plant_out.body' => 'Plant {subject} outside once frost has passed — around {frost_date}.',
			'suggestions.tomato.start_seedlings.title' => 'Start seedlings',
			'suggestions.tomato.start_seedlings.body' => 'Sow {subject} indoors for a head start — by about {window_end_date}.',
			'suggestions.tomato.prick_out.title' => 'Prick out',
			'suggestions.tomato.prick_out.body' => 'You sowed {subject} {days_since} days ago — prick the seedlings into pots.',
			'suggestions.tomato.harden_off.title' => 'Harden off',
			'suggestions.tomato.harden_off.body' => 'Acclimatise {subject} outdoors before planting out — window open until ~{window_end_date}.',
			'suggestions.tomato.transplant.title' => 'Transplant',
			'suggestions.tomato.transplant.body' => '{subject} has grown for {days_since} days — move it to its final position.',
			'suggestions.tomato.stake.title' => 'Stake',
			'suggestions.tomato.stake.body' => '{subject} is {days_since} days on — add a stake or support.',
			'suggestions.shrub.prune_spring.title' => 'Spring pruning',
			'suggestions.shrub.prune_spring.body' => 'Prune {subject} as needed — by about {window_end_date}.',
			'suggestions.shrub.overwinter.title' => 'Winter protection',
			'suggestions.shrub.overwinter.body' => 'Protect {subject} before the first hard frost — by about {window_end_date}.',
			'suggestions.hedge.prune_early_summer.title' => 'Early-summer trim',
			'suggestions.hedge.prune_early_summer.body' => 'Trim {subject} for shape — window open until ~{window_end_date}.',
			'suggestions.hedge.prune_late_summer.title' => 'Late-summer trim',
			'suggestions.hedge.prune_late_summer.body' => 'Give {subject} a final trim before autumn — by about {window_end_date}.',
			'suggestions.conifer.prune.title' => 'Trim',
			'suggestions.conifer.prune.body' => 'Trim {subject} lightly into new growth — by about {window_end_date}.',
			'suggestions.houseplant.repot.title' => 'Repot',
			'suggestions.houseplant.repot.body' => 'Repot {subject} as growth resumes — window open until ~{window_end_date}.',
			'suggestions.houseplant.fertilize_season.title' => 'Feed',
			'suggestions.houseplant.fertilize_season.body' => 'Feed {subject} during the active growing season.',
			'suggestions.houseplant.overwinter.title' => 'Bring indoors',
			'suggestions.houseplant.overwinter.body' => 'Move {subject} indoors before the first frost — by about {window_end_date}.',
			'suggestions.blueberry.prune.title' => 'Pruning',
			'suggestions.blueberry.prune.body' => 'Prune {subject} while dormant — by about {window_end_date}.',
			'suggestions.cherry_laurel.prune_late_spring.title' => 'Late-spring trim',
			'suggestions.cherry_laurel.prune_late_spring.body' => 'Trim {subject} after the first flush — window open until ~{window_end_date}.',
			'suggestions.cherry_laurel.prune_late_summer.title' => 'Late-summer trim',
			'suggestions.cherry_laurel.prune_late_summer.body' => 'Give {subject} a second trim — by about {window_end_date}.',
			'suggestions.hydrangea.prune_old_wood.title' => 'Prune (old wood)',
			'suggestions.hydrangea.prune_old_wood.body' => 'Deadhead and tidy old-wood {subject} after flowering — by about {window_end_date}.',
			'suggestions.hydrangea.prune_new_wood.title' => 'Prune (new wood)',
			'suggestions.hydrangea.prune_new_wood.body' => 'Cut back new-wood {subject} in late winter — by about {window_end_date}.',
			'suggestions.peach.prune_spring.title' => 'Spring pruning',
			'suggestions.peach.prune_spring.body' => 'Prune {subject} as the buds swell to limit leaf curl — by about {window_end_date}.',
			'suggestions.raspberry.prune_late_winter.title' => 'Late-winter pruning',
			'suggestions.raspberry.prune_late_winter.body' => 'Prune {subject} canes before growth starts — by about {window_end_date}.',
			'suggestions.raspberry.prune_after_harvest.title' => 'After-harvest pruning',
			'suggestions.raspberry.prune_after_harvest.body' => '{subject} fruited {days_since} days ago — cut out the old canes.',
			'suggestions.rose.prune_spring.title' => 'Spring pruning',
			'suggestions.rose.prune_spring.body' => 'Prune {subject} as the buds break — by about {window_end_date}.',
			'suggestions.rose.overwinter.title' => 'Winter protection',
			'suggestions.rose.overwinter.body' => 'Mound or wrap {subject} before hard frost — by about {window_end_date}.',
			'suggestions.cucumber.sow_direct.title' => 'Direct sow',
			'suggestions.cucumber.sow_direct.body' => 'Sow {subject} outdoors once it is warm and frost-free — around {frost_date}.',
			'suggestions.zucchini.sow_direct.title' => 'Direct sow',
			'suggestions.zucchini.sow_direct.body' => 'Sow {subject} outdoors after frost — around {frost_date}.',
			_ => null,
		};
	}
}

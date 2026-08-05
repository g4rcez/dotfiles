import { Espanso } from '../../api/espanso'
import { Karabiner } from '../../api/karabiner/karabiner'

export interface SymlinkConfig {
  [target: string]:
    | string
    | {
        source: string
        backup?: boolean
        force?: boolean
        createDirs?: boolean
      }
}

export type Shells = 'zsh' | 'bash' | 'fish'

export interface EnvConfig {
  shells?: Shells[]
  exportFile?: string
  variables: Record<string, string | string[]>
}

export type Empty = Record<string | number | symbol, never>

export type Alphabet =
  | 'a'
  | 'b'
  | 'c'
  | 'd'
  | 'e'
  | 'f'
  | 'g'
  | 'h'
  | 'i'
  | 'j'
  | 'k'
  | 'l'
  | 'm'
  | 'n'
  | 'o'
  | 'p'
  | 'q'
  | 'r'
  | 's'
  | 't'
  | 'u'
  | 'v'
  | 'w'
  | 'x'
  | 'y'
  | 'z'

export type KeyCode =
  | 'caps_lock'
  | 'left_control'
  | 'left_shift'
  | 'left_option'
  | 'left_command'
  | 'right_control'
  | 'right_shift'
  | 'right_option'
  | 'right_command'
  | 'fn'
  | 'return_or_enter'
  | 'escape'
  | 'delete_or_backspace'
  | 'delete_forward'
  | 'tab'
  | 'spacebar'
  | 'hyphen'
  | 'equal_sign'
  | 'open_bracket'
  | 'close_bracket'
  | 'backslash'
  | 'non_us_pound'
  | 'semicolon'
  | 'quote'
  | 'grave_accent_and_tilde'
  | 'comma'
  | 'period'
  | 'slash'
  | 'non_us_backslash'
  | 'up_arrow'
  | 'down_arrow'
  | 'left_arrow'
  | 'right_arrow'
  | 'page_up'
  | 'page_down'
  | 'home'
  | 'end'
  | Alphabet
  | '1'
  | '2'
  | '3'
  | '4'
  | '5'
  | '6'
  | '7'
  | '8'
  | '9'
  | '0'
  | 'f1'
  | 'f2'
  | 'f3'
  | 'f4'
  | 'f5'
  | 'f6'
  | 'f7'
  | 'f8'
  | 'f9'
  | 'f10'
  | 'f11'
  | 'f12'
  | 'f13'
  | 'f14'
  | 'f15'
  | 'f16'
  | 'f17'
  | 'f18'
  | 'f19'
  | 'f20'
  | 'f21'
  | 'f22'
  | 'f23'
  | 'f24'
  | 'display_brightness_decrement'
  | 'display_brightness_increment'
  | 'mission_control'
  | 'launchpad'
  | 'dashboard'
  | 'illumination_decrement'
  | 'illumination_increment'
  | 'rewind'
  | 'play_or_pause'
  | 'fastforward'
  | 'mute'
  | 'volume_decrement'
  | 'volume_increment'
  | 'eject'
  | 'apple_display_brightness_decrement'
  | 'apple_display_brightness_increment'
  | 'apple_top_case_display_brightness_decrement'
  | 'apple_top_case_display_brightness_increment'
  | 'keypad_num_lock'
  | 'keypad_slash'
  | 'keypad_asterisk'
  | 'keypad_hyphen'
  | 'keypad_plus'
  | 'keypad_enter'
  | 'keypad_1'
  | 'keypad_2'
  | 'keypad_3'
  | 'keypad_4'
  | 'keypad_5'
  | 'keypad_6'
  | 'keypad_7'
  | 'keypad_8'
  | 'keypad_9'
  | 'keypad_0'
  | 'keypad_period'
  | 'keypad_equal_sign'
  | 'keypad_comma'
  | 'vk_none'
  | 'print_screen'
  | 'scroll_lock'
  | 'pause'
  | 'insert'
  | 'application'
  | 'help'
  | 'power'
  | 'execute'
  | 'menu'
  | 'select'
  | 'stop'
  | 'again'
  | 'undo'
  | 'cut'
  | 'copy'
  | 'paste'
  | 'find'
  | 'international1'
  | 'international2'
  | 'international3'
  | 'international4'
  | 'international5'
  | 'international6'
  | 'international7'
  | 'international8'
  | 'international9'
  | 'lang1'
  | 'lang2'
  | 'lang3'
  | 'lang4'
  | 'lang5'
  | 'lang6'
  | 'lang7'
  | 'lang8'
  | 'lang9'
  | 'japanese_eisuu'
  | 'japanese_kana'
  | 'japanese_pc_nfer'
  | 'japanese_pc_xfer'
  | 'japanese_pc_katakana'
  | 'keypad_equal_sign_as400'
  | 'locking_caps_lock'
  | 'locking_num_lock'
  | 'locking_scroll_lock'
  | 'alternate_erase'
  | 'sys_req_or_attention'
  | 'cancel'
  | 'clear'
  | 'prior'
  | 'return'
  | 'separator'
  | 'out'
  | 'oper'
  | 'clear_or_again'
  | 'cr_sel_or_props'
  | 'ex_sel'
  | 'left_alt'
  | 'left_gui'
  | 'right_alt'
  | 'right_gui'
  | 'vk_consumer_brightness_down'
  | 'vk_consumer_brightness_up'
  | 'vk_mission_control'
  | 'vk_launchpad'
  | 'vk_dashboard'
  | 'vk_consumer_illumination_down'
  | 'vk_consumer_illumination_up'
  | 'vk_consumer_previous'
  | 'vk_consumer_play'
  | 'vk_consumer_next'
  | 'volume_down'
  | 'volume_up'

export type RectangleActions =
  | 'left-half'
  | 'right-half'
  | 'maximize'
  | 'maximize-height'
  | 'previous-display'
  | 'next-display'
  | 'larger'
  | 'smaller'
  | 'bottom-half'
  | 'top-half'
  | 'center'
  | 'bottom-left'
  | 'bottom-right'
  | 'top-left'
  | 'top-right'
  | 'restore'
  | 'first-third'
  | 'first-two-thirds'
  | 'center-third'
  | 'last-two-thirds'
  | 'last-third'
  | 'move-left'
  | 'move-right'
  | 'move-up'
  | 'move-down'
  | 'almost-maximize'
  | 'fill-left'
  | 'fill-right'
  | 'center-half'
  | 'first-fourth'
  | 'second-fourth'
  | 'third-fourth'
  | 'last-fourth'
  | 'top-left-sixth'
  | 'top-center-sixth'
  | 'top-right-sixth'
  | 'bottom-left-sixth'
  | 'bottom-center-sixth'
  | 'bottom-right-sixth'
  | 'first-sixth'
  | 'last-sixth'
  | 'fullscreen'
  | 'close'
  | 'minimize'
  | 'quit-app'
  | 'hide-app'
  | 'cascade-all'
  | 'cascade-app'
  | 'tile-2x2'
  | 'tile-2x3'
  | 'reveal-desktop-edge'
  | 'app-next-display'
  | 'app-prev-display'
  | 'app-left-half'
  | 'app-right-half'
  | 'first-three-fourths'
  | 'last-three-fourths'
  | 'top-left-ninth'
  | 'top-center-ninth'
  | 'top-right-ninth'
  | 'middle-left-ninth'
  | 'middle-center-ninth'
  | 'middle-right-ninth'
  | 'bottom-left-ninth'
  | 'bottom-center-ninth'
  | 'bottom-right-ninth'
  | 'top-left-third'
  | 'top-right-third'
  | 'bottom-left-third'
  | 'bottom-right-third'
  | 'top-left-eighth'
  | 'top-center-left-eighth'
  | 'top-center-right-eighth'
  | 'top-right-eighth'
  | 'bottom-left-eighth'
  | 'bottom-center-left-eighth'
  | 'bottom-center-right-eighth'
  | 'bottom-right-eighth'
  | 'center-two-thirds'
  | 'fill-bottom-left'
  | 'fill-bottom-right'
  | 'fill-top-left'
  | 'fill-top-right'
  | 'last'
  | 'next-space'
  | 'nudge-left'
  | 'nudge-right'
  | 'nudge-up'
  | 'nudge-down'
  | 'prev-space'
  | 'snap-bottom-left'
  | 'snap-bottom-right'
  | 'snap-top-left'
  | 'snap-top-right'
  | 'upper-center'
  | 'next-display-ratio'
  | 'prev-display-ratio'
  | 'stash-left'
  | 'stash-right'
  | 'stash-up'
  | 'stash-down'
  | 'unstash'
  | 'cycle-stashed'
  | 'toggle-stashed'
  | 'unstash-all'
  | 'stash-all'
  | 'stash-all-but-front'
  | 'reflow-pin'

export interface MouseKey {
  y?: number
  x?: number
  speed_multiplier?: number
  vertical_wheel?: number
  horizontal_wheel?: number
}

export interface SoftwareFunction {
  iokit_power_management_sleep_system?: Empty
}

export interface SimultaneousFrom {
  key_code: KeyCode
}

export interface SimultaneousOptions {
  key_down_order?: 'insensitive' | 'strict' | 'strict_inverse'
  detect_key_down_uninterruptedly?: boolean
}

export interface Modifiers {
  optional?: string[]
  mandatory?: string[]
}

export interface From {
  key_code?: KeyCode
  simultaneous?: SimultaneousFrom[]
  simultaneous_options?: SimultaneousOptions
  modifiers?: Modifiers
}

export interface To {
  halt?: boolean
  set_notification_message?: { id: string; text: string }
  key_code?: KeyCode
  modifiers?: KeyCode[]
  shell_command?: string
  set_variable?: {
    name: string
    value: boolean | number | string
  }
  mouse_key?: MouseKey
  pointing_button?: string
  software_function?: SoftwareFunction
}

export type Parameters = Partial<{
  'basic.to_if_alone_threshold_milliseconds': number
  'basic.to_if_held_down_threshold_milliseconds': number
  'basic.simultaneous_threshold_milliseconds': number
  'basic.to_delayed_action_delay_milliseconds': number
}>

interface Identifiers {
  vendor_id?: number
  product_id?: number
  location_id?: number
  is_keyboard?: boolean
  is_pointing_device?: boolean
  is_touch_bar?: boolean
  is_built_in_keyboard?: boolean
}

interface InputSource {
  language?: string
  input_source_id?: string
  input_mode_id?: string
}

type FrontMostApplicationCondition = {
  type: 'frontmost_application_if' | 'frontmost_application_unless'
  bundle_identifiers?: string[]
  file_paths?: string[]
  description?: string
}

type DeviceCondition = {
  type: 'device_if' | 'device_unless' | 'device_exists_if' | 'device_exists_unless'
  identifiers: Identifiers
  description?: string
}

type KeyboardTypeCondition = {
  type: 'keyboard_type_if' | 'keyboard_type_unless'
  keyboard_types: string[]
  description?: string
}

type InputSourceCondition = {
  type: 'input_source_if' | 'input_source_unless'
  input_sources: InputSource[]
  description?: string
}

type VariableCondition = {
  type: 'variable_if' | 'variable_unless'
  name: string | number | boolean
  value: string | number
  description?: string
}

type EventChangedCondition = {
  type: 'event_changed_if' | 'event_changed_unless'
  value: boolean
  description?: string
}

export type Conditions =
  | FrontMostApplicationCondition
  | DeviceCondition
  | KeyboardTypeCondition
  | InputSourceCondition
  | VariableCondition
  | EventChangedCondition

export interface KarabinerManipulator {
  description?: string
  type: 'basic'
  from: From
  to?: To[]
  to_after_key_up?: To[]
  to_if_alone?: To[]
  to_if_held_down?: To[]
  parameters?: Parameters
  conditions?: Conditions[]
  to_delayed_action?: {
    to_delayed_action?: { to_if_canceled?: To[] }
    to_if_invoked?: To[]
  }
}

/**
 * Layer command for Karabiner
 */
export interface LayerCommand {
  to?: To[]
  conditions?: Conditions[]
  description?: string
  to_after_key_up?: To[]
  parameters?: Parameters
  to_if_held_down?: To[]
  to_if_alone?: To[]
  to_delayed_action?: { to_if_canceled?: To[]; to_if_invoked?: To[] }
  hold?: boolean
}

/**
 * Hyper key sublayer
 */
export type HyperKeySublayer = Partial<Record<KeyCode, LayerCommand>>

/**
 * SubLayers for hyper key
 */
export type SubLayers = Partial<Record<KeyCode, HyperKeySublayer | LayerCommand>>

/**
 * WhichKey documentation item
 */
export interface WhichKey {
  key: string
  description: string
  command: string
}

/**
 * Karabiner rule
 */
export interface KarabinerRule {
  hold?: string
  description?: string
  manipulators: KarabinerManipulator[]
}

/**
 * Karabiner profile
 */
export interface KarabinerProfile {
  name: string
  rules: KarabinerRule[]
}

/**
 * Karabiner configuration
 */
export interface KarabinerConfig {
  profiles: KarabinerProfile[]
  outputPath: string
  whichKeyPath?: string
  whichKeys?: WhichKey[]
}

/**
 * Espanso match variable
 */
export interface EspansoVariable {
  name: string
  type: 'date' | 'shell' | 'clipboard' | 'echo' | 'random' | 'form' | 'choice'
  params?: Record<string, unknown>
}

/**
 * Espanso match
 */
export interface EspansoMatch {
  trigger?: string | string[]
  replace: string
  label?: string
  vars?: EspansoVariable[]
  word?: boolean
  propagate_case?: boolean
  regex?: string
  form?: string
}

/**
 * Espanso builder match (return type from builder methods)
 */
export interface EspansoBuilderMatch {
  trigger?: string | string[]
  replace: string
  label?: string
  vars?: EspansoVariable[]
  word?: boolean
  propagate_case?: boolean
  regex?: string
  form?: string
}

/**
 * Espanso trigger prefix type
 */
export type EspansoTrigger<Prefix extends string> = `${Prefix}${string}`

/**
 * Espanso configuration
 */
export interface EspansoConfig {
  matches: EspansoMatch[]
  imports?: string[]
  outputPath: string
  whichKeyPath?: string
}

/**
 * Supported package managers
 */
export type PackageManager = 'brew' | 'apt' | 'pacman' | 'dnf'

/**
 * Package manager configuration
 */
export interface PackageManagerConfig {
  /** Homebrew packages (macOS) */
  brew?: string[] | { packages?: string[]; import?: string }

  /** APT packages (Debian/Ubuntu) */
  apt?: string[] | { packages?: string[]; import?: string }

  /** Pacman packages (Arch Linux) */
  pacman?: string[] | { packages?: string[]; import?: string }

  /** DNF packages (Fedora/RHEL) */
  dnf?: string[] | { packages?: string[]; import?: string }

  /** Skip sudo confirmation for apt/pacman/dnf */
  autoSudo?: boolean
}

/**
 * Package installation result
 */
export interface PackageInstallResult {
  manager: PackageManager
  package: string
  success: boolean
  alreadyInstalled: boolean
  error?: string
}

/**
 * Lifecycle hooks
 */
export interface Hooks {
  beforeApply?: () => Promise<void> | void
  afterApply?: () => Promise<void> | void
}

/**
 * Karabiner.ts configuration (using karabiner.ts library directly)
 */
export interface KarabinerTsConfig {
  /** Output path for karabiner.json */
  outputPath?: string
  /** Profile name in Karabiner-Elements */
  profileName?: string
  /** Karabiner.ts rules */
  rules: any[] // Using any to avoid importing karabiner.ts types
  /** Global settings */
  global?: {
    check_for_updates_on_startup?: boolean
    show_in_menu_bar?: boolean
    show_profile_name_in_menu_bar?: boolean
  }
}

/**
 * Profile-specific configuration
 * Can override or extend any base config fields
 */
export interface ProfileConfig {
  /** Profile this extends (inheritance) */
  extends?: string
  /** Hostname(s) for auto-selection */
  hostname?: string | string[]
  /** Profile-specific lifecycle hooks */
  hooks?: Hooks
  /** Profile-specific package manager configuration */
  packages?: PackageManagerConfig
  /** Profile-specific VSCode extensions */
  vscode?: { extensions: string | string[] }
  /** Profile-specific symlinks */
  symlinks?: SymlinkConfig
  /** Profile-specific environment */
  env?: EnvConfig
  /** Profile-specific karabiner */
  karabiner?: Karabiner
  /** Profile-specific espanso */
  espanso?: Espanso
}

/**
 * Collection of profiles
 */
export type ProfilesConfig = Record<string, ProfileConfig>

/**
 * Profile selection context
 */
export interface ProfileContext {
  /** Selected profile name */
  profile: string
  /** How profile was selected */
  source: 'cli' | 'env' | 'hostname' | 'default' | 'freeform'
  /** Whether profile exists in config */
  exists: boolean
}

/**
 * Main dotfiles configuration
 */
export interface DotfilesConfig {
  // Base config (applies to all profiles)
  /** Symlink declarations */
  symlinks?: SymlinkConfig
  /** Environment variable management */
  env?: EnvConfig
  /** Karabiner keyboard configuration */
  karabiner?: Karabiner
  /** Espanso text expansion configuration */
  espanso?: Espanso

  // Global sections
  /** Package manager configuration (global) */
  packages?: PackageManagerConfig
  /** Lifecycle hooks (global) */
  hooks?: Hooks
  /** VSCode extensions configuration */
  vscode?: { extensions: string | string[] }

  // Profiles object
  /** Profile-specific configurations */
  profiles?: ProfilesConfig
}

/**
 * Normalized symlink entry for internal use
 */
export interface NormalizedSymlink {
  target: string
  source: string
  backup: boolean
  force: boolean
  createDirs: boolean
}

/**
 * State file structure
 */
export interface StateFile {
  version: string
  lastApplied: string
  /** Currently active profile */
  activeProfile?: string
  symlinks: Array<{
    target: string
    source: string
    createdAt: string
    checksum: string
  }>
  env?: {
    exportFile: string
    injectedShells: string[]
  }
  karabiner?: {
    outputPath: string
    lastGenerated: string
  }
  espanso?: {
    outputPath: string
    lastGenerated: string
  }
  whichKey?: {
    espansoPath?: string
    karabinerPath?: string
    lastGenerated: string
  }
  packages?: {
    installed: Array<{
      manager: PackageManager
      package: string
      installedAt: string
      version?: string
    }>
    lastSync: string
  }
}

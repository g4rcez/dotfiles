export { defineConfig } from './dotfiles.ts'
export { Espanso } from './espanso.ts'
export { Karabiner, type Manipulator } from './karabiner/karabiner.ts'
export { AeroSpace, aerospace } from './karabiner/aerospace.ts'
export { Rectangle, rectangle } from './karabiner/rectangle.ts'
export { packages, importFrom, inlinePackages } from './packages.ts'
export type {
  DotfilesConfig,
  SymlinkConfig,
  EnvConfig,
  KarabinerConfig,
  KarabinerProfile,
  KarabinerRule,
  KarabinerManipulator,
  EspansoConfig,
  EspansoMatch,
  EspansoVariable,
  EspansoBuilderMatch,
  PackageManagerConfig,
  PackageManager,
  Hooks,
  LayerCommand,
  KeyCode,
  RectangleActions,
  SubLayers,
  HyperKeySublayer,
  WhichKey,
  To,
  From,
  Modifiers,
  Conditions,
  Parameters,
  Empty,
  Alphabet,
  // Profile types
  ProfileConfig,
  ProfilesConfig,
  ProfileContext,
} from '../core/config/types.ts'

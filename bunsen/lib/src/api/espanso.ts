import type { EspansoBuilderMatch } from '../core/config/types.ts'

export class Espanso<T extends string = ';'> {
  public trigger: T
  public path = '~/.config/espanso/match/base.yml'
  public whichKeyPath = '~/.config/espanso/whichkey.json'
  public matches: EspansoBuilderMatch[] = []
  public imports: string[] = []

  public constructor(trigger?: T) {
    this.trigger = trigger || (';' as T)
  }

  private makeTrigger = (key: string | string[]): string | string[] => {
    if (Array.isArray(key)) {
      return key.map((k) => `${this.trigger}${k}`)
    }
    return `${this.trigger}${key}`
  }

  private getTriggerKey = (key: string | string[]): string => {
    return Array.isArray(key) ? key[0] : key
  }

  public insert(key: string, syntax: string, label: string) {
    this.matches.push({
      trigger: this.makeTrigger(key),
      replace: syntax,
      label,
    })
    return this
  }

  public random(key: string, choices: string[], label: string) {
    this.matches.push({
      trigger: this.makeTrigger(key),
      replace: `{{${this.getTriggerKey(key)}}}`,
      label,
      vars: [
        {
          name: this.getTriggerKey(key),
          type: 'random',
          params: { choices },
        },
      ],
    })
    return this
  }

  public form(key: string, replace: string, cmd: string, label: string) {
    this.matches.push({
      trigger: this.makeTrigger(key),
      replace,
      label,
      vars: [
        {
          name: 'form',
          type: 'form',
          params: { layout: '[[input]]' },
        },
        {
          name: this.getTriggerKey(key),
          type: 'shell',
          params: { cmd },
        },
      ],
    })
    return this
  }

  public clipboard(key: string, name: string, syntax: string, label: string) {
    this.matches.push({
      trigger: this.makeTrigger(key),
      replace: syntax,
      label,
      vars: [
        {
          name,
          type: 'clipboard',
        },
      ],
    })
    return this
  }

  public format(key: string, type: 'date' | 'shell', format: string, label: string) {
    this.matches.push({
      trigger: this.makeTrigger(key),
      replace: `{{${this.getTriggerKey(key)}}}`,
      label,
      vars: [
        {
          name: this.getTriggerKey(key),
          type,
          params: { format },
        },
      ],
    })
    return this
  }

  public shell(key: string, label: string, cmd: string, capture?: string) {
    const result: EspansoBuilderMatch = {
      replace: `{{${this.getTriggerKey(key)}}}`,
      label,
      vars: [
        {
          name: 'clipboard',
          type: 'clipboard',
        },
        {
          name: this.getTriggerKey(key),
          type: 'shell',
          params: { cmd },
        },
      ],
    }

    if (capture) {
      result.regex = this.makeTrigger(capture) as string
    } else {
      result.trigger = this.makeTrigger(key)
    }
    this.matches.push(result)
    return this
  }
}

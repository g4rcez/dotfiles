import { resolve, normalize } from 'node:path'

export const expandPath = (path: string, homePath: string): string => {
  const expanded = path.startsWith('~/') ? path.replace('~', homePath) : path
  return normalize(
    expanded
      .replace(/\$(\w+)/g, (_, varName) => process.env[varName] || `$${varName}`)
      .replace(/\$\{(\w+)\}/g, (_, varName) => process.env[varName] || `\${${varName}}`)
  )
}

export const resolvePath = (path: string, homePath: string): string =>
  resolve(expandPath(path, homePath))

export const validatePath = (path: string): boolean => {
  const normalized = normalize(path)
  const segments = normalized.split('/')
  return !segments.includes('..')
}

export const isAbsolute = (path: string): boolean => path.startsWith('/')

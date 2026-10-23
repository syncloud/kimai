export function env(name: string, fallback?: string): string {
  const value = process.env[name] ?? fallback
  if (!value) {
    throw new Error(`${name} is not set`)
  }
  return value
}

export interface Zone {
  id: string
  name: string
  status: string
  // Add other properties as needed
}

export interface DnsRecord {
  id: string
  type: string
  name: string
  content: string
  proxied: boolean
  ttl: number
  zone_id: string
  zone_name: string
  // Add other properties as needed
}

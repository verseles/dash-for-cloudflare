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

export interface DnsSetting {
  id: string;
  value: string | boolean | number;
  editable: boolean;
  modified_on: string | null;
}

export interface DnssecDetails {
  status: string;
  multi_signer: boolean;
  // Add other properties from the API response as needed
}

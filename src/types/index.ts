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
  dnssec_multi_signer?: boolean;
  // Properties available when DNSSEC is pending/active
  algorithm?: string;
  digest?: string;
  digest_algorithm?: string;
  digest_type?: string;
  ds?: string;
  flags?: number;
  key_tag?: number;
  key_type?: string;
  modified_on?: string;
  public_key?: string;
}

export interface DnsZoneSettings {
  multi_provider: boolean;
  // Add other properties as needed, e.g., soa, ns_ttl, etc.
}
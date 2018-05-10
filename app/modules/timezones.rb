module Timezones
  
  # Formats an IANA timezone identifier.
  def self.format(timezone)
    return timezone.gsub("/", " - ").gsub("_", " ")
  end
  
  # Returns a list of IANA timezone identifiers.
  def self.list
    return TZInfo::Timezone.all_country_zone_identifiers.sort
  end
  
  # Returns a 2D array of IANA timezone identifiers for use in select boxes.
  def self.select_options
    return list.map{|tz| [format(tz),tz]}
  end
  
end
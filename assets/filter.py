# Path for the newly uploaded CSV file
country_codes_de_latest_path = '/mnt/data/country_codes_de - country_codes_de (2).csv'

# Reload and reprocess with the latest CSV file
done_codes = set()
with open(country_codes_de_latest_path, 'r', encoding='utf-8') as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        if row.get("DONE?") and row["DONE?"].strip():  # Non-empty "DONE?" column
            code = row.get("Code")
            if code:
                done_codes.add(code.strip())

# Corrected logic to ensure no overlaps between used and unused countries
used_countries = []
unused_countries = []

for country in countries:
    country_code = country.get("id")
    if country_code in done_codes:
        used_countries.append(country)
    else:
        unused_countries.append(country)

# Write the corrected JSON outputs again
with open(data_json_path, 'w', encoding='utf-8') as f:
    json.dump(used_countries, f, ensure_ascii=False, indent=2)

with open(data_unused_json_path, 'w', encoding='utf-8') as f:
    json.dump(unused_countries, f, ensure_ascii=False, indent=2)

# Return the counts of used and unused countries for verification
len(used_countries), len(unused_countries)
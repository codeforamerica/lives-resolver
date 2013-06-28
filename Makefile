all: king-county-live sf-canned

# fetches a fixed test set from S3
king-county-canned:
		mkdir -p king_county 
		curl -o king_county/Food_Establishment_Inspection_Data.csv 'https://s3.amazonaws.com/data.codeforamerica.org/lives/King+County/Food_Establishment_Inspection_Data.csv'

# fetches the live data from King County
king-county-live:
	 	mkdir -p king_county
	 	curl -o king_county/Food_Establishment_Inspection_Data.csv 'https://data.kingcounty.gov/api/views/f29f-zza5/rows.csv?accessType=DOWNLOAD'

# fetches fixed test set from SF CfA Brigade Github account
sf-canned:
		mkdir -p san_francisco
		curl -o san_francisco/lives-sf.csv https://raw.github.com/sfbrigade/SFLivesData/master/lives-sf.csv

clean: 
		rm king_county/Food_Establishment_Inspection_Data.csv
		rmdir -p king_county
		rmdir -p san_francisco
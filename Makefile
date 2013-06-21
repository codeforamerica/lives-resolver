all: king-county-live

king-county-canned:
		mkdir -p king_county 
		curl -o king_county/Food_Establishment_Inspection_Data.csv 'https://s3.amazonaws.com/data.codeforamerica.org/lives/King+County/Food_Establishment_Inspection_Data.csv'

king-county-live:
	 	mkdir -p king_county
	 	curl -o king_county/Food_Establishment_Inspection_Data.csv 'http://www.datakc.org/api/views/f29f-zza5/rows.csv?accessType=DOWNLOAD'

clean: 
		rm king_county/Food_Establishment_Inspection_Data.csv
		rmdir -p king_county
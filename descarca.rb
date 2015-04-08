#!/usr/bin/env ruby
# encoding: utf-8
require 'savon'
require 'csv'
 
 
startDate = Date.new(2004, 01, 01)
stopDate = Date.today
csvHeaders = ['numar', 'numar_vechi', 'data', 'institutie', 'departament',
                                'categorie_caz', 'stadiu_procesual', 'obiect', 'data_modificare','nume','calitate_parte','solutie']
# csvPartHeaders = ['numar', 'numar_vechi', 'data', 'institutie', 'departament',
#                               'categorie_caz', 'stadiu_procesual', 'obiect', 'data_modificare']
# CITIRE INSTITUTII  ========================
f = File.open("Files/institutii.txt", "r")
institutii = [] #
f.each_line do |line|
        line = line.strip || line
        institutii << line
        fileName = "Files/" + line + ".csv"
        if (!File.exist?(fileName))
                File.open(fileName, 'w')
        end
end
f.close
#SFARSIT CITIRE INSTITUTII ==================
 
 
client = Savon.client(wsdl: 'http://portalquery.just.ro/query.asmx?WSDL')
client.operations
 
#CITIRE DOSARE / INSTITUTIE / DATA START / DATA STOP / INTERVAL 15 ZILE
institutii.each do |inst|
        instFile = 'Files/' + inst + '.csv'
        CSV.open(instFile, 'w',
                :write_headers=> true,
        :headers => csvHeaders ) do |csv_object|
                while (startDate < stopDate) do
                        start = startDate.strftime('%Y-%m-%d')
                        startDate += 8
                        stop = startDate.strftime('%Y-%m-%d')
                        response = client.call(:cautare_dosare, message:
                                {institutie: inst, data_start: start, data_stop: stop})
                        dosare = response.body[:cautare_dosare_response][:cautare_dosare_result][:dosar]
                        if  dosare != nil
                                dosare.each do |dosar|

dosarParteNume = ""
dosarCalitateParte = ""
if dosar[:parti] && dosar[:parti][:dosar_parte]
  [dosar[:parti][:dosar_parte]].flatten.each do |parte|
    dosarParteNume << parte[:nume] + "#" if parte[:nume]
    dosarCalitateParte << parte[:calitate_parte] + "#" if parte[:calitate_parte]
  end
end
 
dosarsedintasolutie = ""
dosarsedintasolutiesumar = ""
if dosar[:sedinte] && dosar[:sedinte][:dosar_sedinta]
  [dosar[:sedinte][:dosar_sedinta]].flatten.each do |sedinta|
    dosarsedintasolutie << sedinta[:solutie] + "#" if sedinta[:solutie]
    dosarsedintasolutiesumar << sedinta[:solutie_sumar] + "#" if sedinta[:solutie_sumar]
  end
end
								
									# Acum le punem pe toate intr-un singur loc
										toPut = [dosar[:numar], dosar[:numar_vechi],
                                                dosar[:data], dosar[:institutie],
                                                dosar[:departament],
                                                dosar[:categorie_caz],
                                                dosar[:stadiu_procesual],
                                                dosar[:obiect].to_s.gsub("\n",' '),
                                                dosar[:data_modificare],
                                                dosarParteNume,
												dosarCalitateParte,
												dosarsedintasolutie,
												dosarsedintasolutiesumar]
                                        csv_object << toPut
                                        puts dosar[:numar]
                                end
                                # customers.array.each do |row_array|
                                #     csv_object << row_array  
                                # end          
                        end
                end    
        end
end

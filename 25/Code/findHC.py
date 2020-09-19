# Get a list of HCs in the same city as the caller
nearbyHc = HealthCenter.objects.all()

# Getting a list of tuple of the coords of the nearby HCs
nearbyHcCoords = list()
for hc in nearbyHc:
    nearbyHcCoords.append((hc.latitude, hc.longitude))

# Query the Distance Matrix API to help find the closest HC
distMatResponse = gmapsClient.distance_matrix(
    patientCoords, nearbyHcCoords

)
# Finding the distance of closest HC from the current location of the
# patient. There will always be a single source and so we can hardcode
# to fetch only the first row in the response.
minDist = 9999999999
hcIdx = -1
for (i, element) in enumerate(distMatResponse['rows'][0]['elements']):
    if element['distance']['value'] < minDist:
        minDist = element['distance']['value']
        hcIdx = i
        
# Now that a suitable HC is found allocate the case to the HC
suitableHc = nearbyHc[hcIdx].hc.username 
print(nearbyHc[hcIdx].name)
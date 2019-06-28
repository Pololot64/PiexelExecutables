#Mod Parameters
const mod_type = "map_gen"
const priority = "0"

#This is the default PieXel Mapgen v0.4



static func _on_load(map_seed, biome, WORLD_WIDTH, SKY_HEIGHT, GROUND_DEPTH, api):  #Every mod has a on_load function
	print("Init Mod")
	#Insert whatever gibberish makes the map here
	var WORLD_HEIGHT = SKY_HEIGHT + GROUND_DEPTH
	#Start by generating landfform heights and filling the ground with dirt/minerals
	if len(str(map_seed)) > 4:
		map_seed = 5678
	var mountain_max_height = biome["_mountainous"]
	
	#This is the noise used to make the mountains
	var land_noise = OpenSimplexNoise.new()
	land_noise.seed = map_seed
	land_noise.octaves = 1
	land_noise.period = biome["_landscape_smoothness"]
	land_noise.lacunarity = 0.3
	land_noise.persistence = 0.2
	
	#get ground heights
	var ground_heights = []
	for x in WORLD_WIDTH:
		var height_noise = land_noise.get_noise_2d(float(x), float(0))
		height_noise = (height_noise + 1) / 2
		var height = height_noise * mountain_max_height
		ground_heights.append(int(height))
	#Add features on and above the terrain's surface
	
	#surface noise generator
	var surface_noise = OpenSimplexNoise.new()
	surface_noise.seed = map_seed + 2394797983 #Make the seed different
	surface_noise.octaves = 1
	surface_noise.period = biome["_surface_variety"]
	surface_noise.lacunarity = 0.3
	surface_noise.persistence = 0.2
	
	#vegetation noise generator
	var vegetation_noise = OpenSimplexNoise.new()
	vegetation_noise.seed = map_seed + 3847590397 #Make the seed different
	vegetation_noise.octaves = 1
	vegetation_noise.period = biome["_vegetation_variety"]
	vegetation_noise.lacunarity = 0.3
	vegetation_noise.persistence = 0.2
	
	
	
	var surface = []
	var vegetation = []
	for w in WORLD_WIDTH:
		surface.append(surface_noise.get_noise_2d(float(w), float(0)))
		vegetation.append(vegetation_noise.get_noise_2d(float(w), float(0)))
		
	
	
	
	#Create a list named world and fill it. Calculate minerals at the same time
	var world = []
	var walls = []
	for h in WORLD_HEIGHT:
		var row = []
		for w in WORLD_WIDTH:
			row.append("")
		world.append(row)
		walls.append(row)
	#Noise used to generate underground area
	var mineral_noise = OpenSimplexNoise.new()
	mineral_noise.seed = map_seed + 9873459037 #Make the seed different
	mineral_noise.octaves = 1
	mineral_noise.period = biome["_mineral_variety"]
	mineral_noise.lacunarity = 0.3
	mineral_noise.persistence = 0.2
	
	for w in WORLD_WIDTH:
		#Fill the mountains with blocks
		var cave_offset = 20
		for h in range(SKY_HEIGHT - ground_heights[w], SKY_HEIGHT):
			var block = mineral_noise.get_noise_2d(float(w), float(h))
			block = str(api.mapgen_get_tile(block, biome, "mineral"))
			world[h][w] = block
		
		
		
				
		
			
		#Fill the earth with minerals
		for h in range(SKY_HEIGHT, WORLD_HEIGHT):
			var block = mineral_noise.get_noise_2d(float(w), float(h))
			block = str(api.mapgen_get_tile(block, biome, "mineral"))
			world[h][w] = block
			
		for h in range(SKY_HEIGHT - ground_heights[w], SKY_HEIGHT):
			#Make sure caves are deeper
			var depth = h - (SKY_HEIGHT - ground_heights[w]) - 1
			if world[h][w] == "cave" and depth < 1:
				for i in range(int(mountain_max_height / 3)):
					#world[SKY_HEIGHT - ground_heights[w] + depth + i + 1][w] = "gold"
					world[SKY_HEIGHT - ground_heights[w] + i][w] = "dirt"
				
				break	
		
			
			
			
	    #grow the grass... whatever the player will step on :-)
		world[SKY_HEIGHT - ground_heights[w]][w] = api.mapgen_get_tile(surface[w], biome, "surface")
		
	
		
		
		#Add vegetation to the world. This includes rocks XP Could not find a better name
		var vegetation_type = api.mapgen_get_tile(surface[w], biome, "vegetation")
		world[SKY_HEIGHT - ground_heights[w] - 1][w] = vegetation_type
		
		#Make sure nothing is growing on water...
		if api.mapgen_get_tile(surface[w], biome, "surface") == "water":
			world[SKY_HEIGHT - ground_heights[w] - 1][w] = ""
			vegetation_type = "None"
		
		
		
		#make trees work
		if vegetation_type == "tree":
			
			var tree_height_noise = (mineral_noise.get_noise_2d(float(w), float(0)) + 1) / 2
			var tree_height = int(tree_height_noise * biome["_tree_height"])
			
			if tree_height < 4:
				tree_height = 7
			
			#make the base have a stump
			#world[SKY_HEIGHT - ground_heights[w]][w] = biome["tree"]["base"]
			var current_tile = 1
			while current_tile < tree_height:
				world[SKY_HEIGHT - ground_heights[w] - current_tile][w] = biome["tree"]["trunk"]
				current_tile += 1
			
			#add top of tree
		
			
			var height_of_leaves = len(biome["tree"]["grid"])
			for y in range(0, height_of_leaves):
				var side_leaves_extend = int(len(biome["tree"]["grid"][y]) / 2.0)
				var current = -1 * side_leaves_extend
				for i in biome["tree"]["grid"][y]:
					world[SKY_HEIGHT - ground_heights[w] - tree_height + y][w + current] = "leaf"#biome["tree"]["leaves"][i]
					current += 1
		#Just add water
			
		#add a bottom wall to the world
		world[WORLD_HEIGHT - 1][w] = "dirt"
			
					
				
	return world # Voila... a mapgen mod


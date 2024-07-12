extends Control

@onready var file = "res://Text_assets/words_alpha.txt"
@onready var test_file = "res://Text_assets/words_test.txt"
var characters = 'abcdefghijklmnopqrstuvwxyz'

#when the app opens, it generates a 3 character "word" and searches the dictionary for it
func _ready():
	var start_string = generate_word(characters, 3)
	%TextInput.placeholder_text = start_string
	var words_string = FileAccess.get_file_as_string(file)
	var words_array = words_string.split("\r\n")
	var psa_array = check_input(start_string, words_array)
	change_textbox(psa_array)

#creates a random "word" of random length
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
	
#Given a string against which you may check, and an array of words (a dictionary),
	#this func creates a regex to compare the two, and returns an array of PSAs, those
	#arrays containing different strings fitting different conditions set by the "player"
func check_input(input_string, words_array):
	var good_words:PackedStringArray
	var perfect_words:PackedStringArray
	var reg = create_in_regex(input_string)
	var perfReg = create_perfect_regex(input_string)
	for str in words_array:
		var result = reg.search(str)
		if result:
			#print(str)
			good_words.append(str)
			var perfResult = perfReg.search(str)
			if perfResult:
				perfect_words.append(str)
	var psa_array = [good_words, perfect_words]
	return psa_array


# This function takes in a string and returns a regex that matches for any number of characters,
	# then the first character, then any number of characters, then the second character, and so on
func create_in_regex(regInput):
	var regString = "^"
	var counter = 0
	for char in regInput:
		regString+=".*" + regInput[counter].to_lower()
		counter+=1
	regString+= ".*$"
	var reg = RegEx.new()
	reg.compile(regString)
	return reg

# This function takes in a string and returns a regex that matches for one characters,
	# then the first character, then one characters, then the second character, and so on
func create_perfect_regex(regInput):
	var regString = "^"
	var counter = 0
	for char in regInput:
		regString+="." + regInput[counter].to_lower()
		counter+=1
	regString+= ".$"
	var reg = RegEx.new()
	reg.compile(regString)
	return reg

#Given a PSA array, sets the textbox of the wordslist to a 
	#properly formatted output list of words
func change_textbox(psa_array):#, line_limit):

	#var start_time = Time.get_ticks_usec()
	for child in %LabelsContainer.get_children():
		child.queue_free()
	var good_words:PackedStringArray = psa_array[0]
	var perfect_words:PackedStringArray = psa_array[1]
	var output_string:String = "Perfect words:\n\n"
	var string_line_limit = 39
	#200 is 13 seconds
	#400 is 15 seconds
	#800 is 20 seconds
	#100 is 13 seconds again
	#80 is 12 (high end of 12) check out func test() yikers!
	var label_counter = 0
	var line_counter = 0
	var output_array:PackedStringArray
	for str in perfect_words:
		output_string += str + "\n"
		if line_counter > string_line_limit:
			output_array.append(output_string)
			output_string = ""
			label_counter += 1
			line_counter = 0
			#print(label_counter)
		line_counter += 1
	output_string += "\nGood words\n\n"
	for str in good_words:
		output_string+=str + "\n"
		if line_counter > string_line_limit:
			output_array.append(output_string)
			output_string = ""
			label_counter += 1
			line_counter = 0
			#print(label_counter)
		line_counter += 1
	output_array.append(output_string)
	label_counter+=1
	for str in output_array:
		var word_list = Label.new()
		word_list.text = str
		%LabelsContainer.add_child(word_list)
	#return Time.get_ticks_usec()-start_time




#This function simply tests the split to put the output_strings into the labels
	#In order to have maximum efficiency, we need labels that have split strings,
	#not just one label, and not 479,000 either
	#this function found that the best number of lines to put into each label was 39
	#this is tested on the most difficult case, an empty regex
func test(test_min, test_max, test_step):
	var words_string = FileAccess.get_file_as_string(file)
	var words_array = words_string.split("\r\n")
	var psa_array = check_input("", words_array)
	var test_count = test_min
	var microseconds:Array
	var lowest_micros
	var lowest_micros_count = test_count
	while test_count < test_max:
		var test_micros = change_textbox(psa_array)#, test_count)
		if test_count == lowest_micros_count:
			lowest_micros = test_micros
		if test_micros < lowest_micros:
			lowest_micros = test_micros
			lowest_micros_count = test_count
		var test_output:String = "Test_count: " + str(test_count) + ", Microseconds: " + str(test_micros) 
		microseconds.append(test_micros)
		test_count += test_step
		print(test_output)
	#print(test_strings)
	
	
	print("The lowest was when test_count was " + str(lowest_micros_count) + ", fastest speed was: " + str(lowest_micros))


func _on_button_pressed():
	_on_text_input_text_submitted(%TextInput.text)


#when the "player" hits enter, this func changes the placeholder text and deletes
	#what they typed, and puts a new output into the wordslist
func _on_text_input_text_submitted(new_text):
	%TextInput.text = ""
	%TextInput.placeholder_text = new_text
	var words_string = FileAccess.get_file_as_string(file)
	var words_array = words_string.split("\r\n")
	var psa_array = check_input(new_text, words_array)
	change_textbox(psa_array)#, 50)

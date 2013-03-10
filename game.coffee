# Set these lower for testing, 10k and 4 seemed to work well
NUM_GAMES_IN_SAMPLE = 1000000
NUM_ITEMS_IN_GAME = 9
WIN = true

run_simulation = (contestant) ->
    games_won = 0
    for game_count in [1..NUM_GAMES_IN_SAMPLE]
        games_won++ if run_game(contestant) is WIN

    console.log """#{contestant.name} won #{games_won} games
        (#{games_won / NUM_GAMES_IN_SAMPLE * 100})%"""

run_game = (contestant) ->
    contestant.start_game(game_size: NUM_ITEMS_IN_GAME)

    inputs = (Math.random() for x in [1..NUM_ITEMS_IN_GAME])
    guesses = ([input, contestant.guess_index(input)] for input in inputs)
    inputs_in_order = inputs[..].sort()
    return all(guesses, (input_then_index_guess) ->
        [input, index_guess] = input_then_index_guess
        return inputs_in_order[index_guess] is input
    )

all = (list, test_func) ->
    for item in list
        return false if not test_func(item)
    return true

sample_contestant = {
    start_game: (configs) -> @game_size = configs.game_size
    guess_index: (input) -> Math.floor((Math.random() * @game_size))
    name: "Random Guess"
}

shuffle_contestant = {
    start_game: (configs) ->
        @game_size = configs.game_size
        @previous_guesses = [-1]
    guess_index: (input) ->
        guess = -1
        while guess in @previous_guesses
            guess = Math.floor((Math.random() * @game_size))
        @previous_guesses.push guess
        return guess
    name: "Random (Shuffled) Guess"
}

assume_linear_contestant = {
    start_game: (configs) -> @game_size = configs.game_size
    guess_index: (input) ->
        Math.floor((input * @game_size))
    name: "Assume linear distribution"
}

take_advantage_of_priors_contestant = {
    start_game: (configs) ->
        @game_size = configs.game_size
        @prior_guesses = []  # input, guess tuples
    guess_index: (cur_num) ->
        # set boundaries for reasonable max, min guesses (not including max/min)
        [min, max] = [-1, @game_size]
        for [prior_num, index] in @prior_guesses
            max = index if prior_num > cur_num and max > index
            min = index if prior_num < cur_num and min < index

        # guess randomly within boundaries
        guess = Math.floor(Math.random() * (max - (min + 1))) + (min + 1)
        @prior_guesses.push [cur_num, guess]
        return guess
    name: "assume knowledge of priors"
}

priors_and_better_guesses_contestant = {
    start_game: (configs) ->
        @game_size = configs.game_size
        @prior_guesses = []  # [input, guess] tuples
    guess_index: (cur_num) ->
        # set boundaries for reasonable max, min guesses (not including max/min)
        [min, max, min_num, max_num] = [-1, @game_size, 0, 1]

        for [prior_num, index] in @prior_guesses
            [max, max_num] = [index, prior_num] if prior_num > cur_num and max > index
            [min, min_num] = [index, prior_num] if prior_num < cur_num and min < index

        # guess expectation within boundaries
        percentage_across_boundary = (cur_num - min_num) / (max_num - min_num)
        range = (max - min) - 2  # if min=0, max=4, options=1,2,3, range=2
        guess = Math.floor(percentage_across_boundary * range) + (min + 1)
        #console.log "Guess:", @prior_guesses, cur_num, max, min, guess
        @prior_guesses.push [cur_num, guess]
        return guess
    name: "priors + expected value guessing"
}

run_simulation contestant for contestant in [
    sample_contestant, shuffle_contestant, assume_linear_contestant,
    take_advantage_of_priors_contestant, priors_and_better_guesses_contestant]

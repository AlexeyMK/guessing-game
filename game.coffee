NUM_GAMES_IN_SAMPLE = 1000000
NUM_ITEMS_IN_GAME = 9
WIN = true

run_simulation = (contestant) ->
    games_won = 0
    for game_count in [1..NUM_GAMES_IN_SAMPLE]
        games_won++ if run_game(contestant) is WIN

    console.log """Contestant won #{games_won} games
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
}

run_simulation sample_contestant

# Set these lower for testing, 10k and 4 seemed to work well
NUM_GAMES_IN_SAMPLE = 1000000
NUM_ITEMS_IN_GAME = 9
WIN = true

# useful for debugging
index_failed = []
low_high = {}

run_simulation = (contestant) ->
    games_won = 0
    index_failed = (0 for x in [0..10])
    low_high = {low: 0, high: 0}
    for game_count in [1..NUM_GAMES_IN_SAMPLE]
        games_won++ if run_game(contestant) is WIN

    console.log """#{contestant.name} won #{games_won} games
        \t(#{games_won / NUM_GAMES_IN_SAMPLE * 100})%
        \tFailures: #{index_failed}
        \tLow=#{low_high['low']}, High=#{low_high['high']}"""

run_game = (contestant) ->
    contestant.start_game(game_size: NUM_ITEMS_IN_GAME)

    inputs = (Math.random() for x in [1..NUM_ITEMS_IN_GAME])
    guesses = ([input, contestant.guess_index(input)] for input in inputs)
    inputs_in_order = inputs[..].sort()
    return all(guesses, (input_then_index_guess) ->
        [input, index_guess] = input_then_index_guess
        low_high['low']++ if inputs_in_order[index_guess] > input
        low_high['high']++ if inputs_in_order[index_guess] < input
        return inputs_in_order[index_guess] is input
    )

all = (list, test_func) ->
    for item, index in list
        index_failed[index]++ if not test_func(item)
        return false if not test_func(item)
    return true

sample_contestant = {
    start_game: (configs) -> @game_size = configs.game_size
    guess_index: (input) -> Math.floor((Math.random() * @game_size))
    name: "Random Guess"
}

# borrowing from a Python pattern
if require.main is module
    run_simulation sample_contestant
else
    module.exports =
        run_simulation: run_simulation

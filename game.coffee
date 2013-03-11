# Set these lower for testing, 10k and 4 seemed to work well
NUM_GAMES_IN_SAMPLE = 1000000
NUM_ITEMS_IN_GAME = 9
WIN = true

# useful for debugging
index_failed = []
low_high = {}
first_guess_to_success_count = [] # first guess --> [win/lose tuple]

run_simulation = (contestant) ->
    games_won = 0
    index_failed = (0 for x in [1..NUM_ITEMS_IN_GAME])
    low_high =
        low: 0
        high: 0
    first_guess_to_success_count = ([0,0] for x in [1..NUM_ITEMS_IN_GAME])
    for game_count in [1..NUM_GAMES_IN_SAMPLE]
        games_won++ if run_game(contestant) is WIN

    first_guess_to_success_rate =
        ("#{index}: %#{100 * wins / (wins + losses)}" \
        for [losses, wins], index in first_guess_to_success_count).join("\n")

    console.log """#{contestant.name} won #{games_won} games
        \t(#{games_won / NUM_GAMES_IN_SAMPLE * 100})%
        \tFailures: #{index_failed}
        \tLow=#{low_high['low']}, High=#{low_high['high']}
        \tFirst Guess to Success Rate: \n#{first_guess_to_success_rate}"""

run_game = (contestant) ->
    contestant.start_game
        game_size: NUM_ITEMS_IN_GAME

    inputs = (Math.random() for x in [1..NUM_ITEMS_IN_GAME])
    guesses = ([input, contestant.guess_index input] for input in inputs)
    inputs_in_order = inputs[..].sort()
    won = all(guesses, (input_then_index_guess) ->
        [input, index_guess] = input_then_index_guess
        low_high['low']++ if inputs_in_order[index_guess] > input
        low_high['high']++ if inputs_in_order[index_guess] < input
        inputs_in_order[index_guess] is input
    )
    first_guess_was_correct = \
        inputs_in_order[guesses[0][1]] is guesses[0][0]
    if first_guess_was_correct
        first_guess_to_success_count[guesses[0][1]][Number(won)]++
    won

all = (list, test_func) ->
    for item, index in list
        index_failed[index]++ if not test_func item
        return false if not test_func item
    true

sample_contestant =
    start_game: (configs) -> @game_size = configs.game_size
    guess_index: (input) -> Math.floor (Math.random() * @game_size)
    name: "Random Guess"

# borrowing from a Python pattern
if require.main is module
    run_simulation sample_contestant
else
    module.exports =
        run_simulation: run_simulation

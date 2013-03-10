NUM_GAMES_IN_SAMPLE = 10000
WIN = 1

run_simulation = (contestant) ->
    games_won = 0
    for game_count in [1..NUM_GAMES_IN_SAMPLE]
        games_won++ if run_game(contestant) is WIN

    console.log """Contestant won #{games_won} games
        (#{games_won / NUM_GAMES_IN_SAMPLE * 100}%"""

run_game = (contestant):
    contestant.start_game()

    inputs = [Math.random() for x in [1..10]]
    guesses = [(input, constant.guess_index(input)) for input in inputs]
    inputs_in_order = inputs[..].sort()
    for input, index_guess in contestant_guesses
        if inputs_in_order[index_guess] isnt input
            return false
    return true

sample_contestant = {
    start_game: -> "whateva"
    guess_index: (input) -> (Math.random() * 10) % 10

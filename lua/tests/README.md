# renamer.nvim tests

This directory holds the tests for `renamer.nvim`. In here you will find the all
the information needed to write, run and understand those tests.

## Frameworks and dependencies

Tests are possible through the [busted][busted] and [luassert][luassert]
implementation that [plenary.nvim][plenary] provides. It uses the **busted**
framework to structure and run the tests and **luassert** for mocking the Neovim
API or `renamer` methods which should not be validated by the respective unit
test.

## Running tests

To run the tests you can either use the `make test` command (from the project root)
or the more complex:

```bash
nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './scripts/minimal_init.vim' }"
```

In order to properly run, the tests require a minimal Neovim setup to be made
before they are actually ran, which is defined in `scripts/minimal_init.vim`.
**plenary** also needs to be aware of where tests are found, which is done by
specifying the `PlenaryBustedDirectory`.

## Style

All tests must follow the AAA (Arrange, Act, Assert) pattern. The structure of
unit tests should be:

```lua
describe(<component_name>, function()
    describe(<subcomponent_name>, function()
        it(<tested_behaviour_description>, function()
            -- arrange
            -- ...

            -- act
            -- ...

            -- assert
            -- ...
        end)
    end)

    -- or

    it(<tested_behaviour_description>, function()
        -- arrange
        -- ...

        -- act
        -- ...

        -- assert
        -- ...
    end)
end)
```

An example of this style would be:

```lua
describe('renamer', function()
    describe('on_close', function()
        it('should delete valid buffer', function()
            -- arrange
            -- ...

            -- act
            -- ...

            -- assert
            -- ...
        end)
    end)
end)
```

Tests should not cover the same behaviour twice or more, if possible. For
example, if a tests validates the behaviour when a window ID is invalid, a test
validating the behaviour when a buffer ID is invalid should not check the former
again.

[busted]: https://olivinelabs.com/busted/
[luassert]: https://github.com/Olivine-Labs/luassert
[plenary]: https://github.com/nvim-lua/plenary.nvim/
[plenary-tests]: https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md


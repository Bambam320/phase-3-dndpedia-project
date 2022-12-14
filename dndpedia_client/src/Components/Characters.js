// functional imports
import React, { useContext } from 'react';
import Charactercards from './CharacterCards';
import { LoggedContext } from './LoggedContext';
import { Outlet, useNavigate } from 'react-router-dom';

//material ui imports
import Container from '@material-ui/core/Container';
import Grid from '@material-ui/core/Grid';

function Characters() {

  // sets navigate to be used after the delete action is updated in state
  const navigate = useNavigate()

  // grabs the characters, opponent, myFighter state from context and all of their setter functions
  const { characters, setCharacters, opponent, setOpponent, myFighter, setMyFighter } = useContext(LoggedContext)

  // function is passed back as props from CharacterCards, this updates the characters held in state to remove the user requested deleted character, it also checks
  // if the currently set champion or challenger is the deleted character and removes that character held in its state as well, then navigates back to characters
  function handleDeleteCharacter(id) {
    const newCharacters = characters.filter((character) => character.id != id)
    setCharacters(newCharacters)
    if (myFighter.card.id === id) {
      setMyFighter({
        card: {
          name: '',
          id: 0
        }
      })
    } 
    if (opponent.card.id === id) {
      setOpponent({
        card: {
          name: '',
          id: 0
        }
      })
    }
    navigate('/characters')
  }

  // lists a card for each character held in state, it passes card which represents each character and passes the delete function as props
  const listCharacters = characters.map((singleCharacter) => {
    return (
      <React.Fragment key={singleCharacter.id} >
        <Grid item={4}>
          <Charactercards card={singleCharacter} onDeleteCharacter={handleDeleteCharacter} />
        </Grid>
      </React.Fragment>
    )
  })

  // returns a container and grid for spacing then calls listCharacters to render a component for each card
  return (
    <>
      <Container style={{ margin: '-600px', marginLeft: 'auto', marginRight: 'auto' }}>
        <Grid container spacing={10} justifyContent="space-evenly" columnspacing={10}>
          {listCharacters}
        </Grid>
      </Container>
      <Outlet />
    </>
  )
};

export default Characters;

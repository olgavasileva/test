# Crashmob

  ## Feed Logic

    When a user asks a question, it can be targeted to certain other users or it can be made available to all users.


    ### Web visitor who is not logged in

      #### Public Questions
        When a question is availale to all users, it becomes a candidate to be selected using the feed logic criteria.
        When not logged in, the feed will be determined by the **blind feed algorithm** (TBD - for now, a random sample)

        When a visitor to the website is not logged in, they will only see


    ### Logged in web or mobile user

      #### Targeted Questions
        When a question is targeted to specific users, such as followers or people with a certain tag, it is not available to the general population.

        Targeted questions automatically appear first in the feed, ordered by newest to oldest.

      #### Public Questions
        Public questions are selected based on the **feed algorithm** (TBD - for now, a random sample)


  ## Feed Model

    The user has a feed list which is a list of at qestions that will be presented to them.
    The feed receives questions in two ways.

      1. When a targeted question's target group includes the user, the question is immediately added to their feed
      2. When an public question is created, it is a candidate for the feed, but will only be added when the feed requests more questions

    ### Filling the feed

      On demand, batches of public questions will be added to the feed using the **feed algorithm**

    ### Presenting the feed

      Targeted questions will be first, ordered from newest to oldest, followed by public questions, also ordered newest to oldest.

      The feed will be "paged" by the UI

      When the UI requests a page beyond the end of the feed, the feed will attempt to fill in from public questions.  If there are no appropriate public questions available, the feed will return whatever remains (i.e. from 0 to max number of questions on a page)

display: block;
font-size: 1.4rem;
width: 100%;
background-color: transparent;
border: solid 1px transparent;
color: white;
overflow: auto;
text-align: center;
resize: none;
outline: none;
-webkit-box-shadow: none;
box-shadow: none;
margin: 0;
padding: 0;
border-radius: 0;
min-height: 4.2rem;
max-height: 4.2rem;
/* vertical-align: middle; */


question-builder .question .over_image_title_container {
overflow: visible;
background-color: rgba(87, 87, 87, 0.75);
padding: 5px;
width: 100%;
color: white;
font-size: 22px;
position: absolute;
top: 40%;
}

imagechoice .question .over_image_title_container .image_control, .multiplechoice .question .over_image_title_container .image_control, .prioritizer .question .over_image_title_container .image_control {
font-size: 4rem;
position: absolute;
bottom: 165%;
width: 100%;
width: 100%;
}
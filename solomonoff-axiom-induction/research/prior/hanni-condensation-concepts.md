<!-- Copy of a Google Doc by Kaarel Hänni (draft essay on condensation and the nature of concepts), pasted by the author into the session on 2026-10-15 because the Google Docs link was unreachable from the session. Linked slides ("models and concepts") were not available. -->

meta note: Jeremy and Sam expressed interest in me writing something about what I consider to be issues with condensation, so I'm doing that. I wrote the first section today and am sending it now. In the next few days, I want to write another section listing [desiderata I expect condensation to not meet]/[intended purposes I expect condensation to be inadequate for]/[unit tests I expect condensation to fail], and then I want to think some more about whether I really expect these failures and write a section on why, including giving my thoughts on the argument via the objectivity theorem for condensation working. There might end up being some other sections as well.
disclaimers:

* This will all be about versions of condensation that have been specified or nearly specified currently — the claims here are not about substantially different versions of condensation that could exist in the future.
* I am not implying that Sam is unaware of these issues.

Section 1. Condensation is wrong about the nature of concepts
less clickbaity section title: The type of thing a concept is in condensation (or at least any currently specified version of condensation) is very different from the type of thing a human concept is.

* In condensation, concepts are code snippets combined to generate predictions.[1] This is a very poor specification of what a concept is, or at least of what a human concept is.
   * Like, you can sometimes do some thinking which uses concepts to generate predictions, and it is plausibly fine to view these concepts as being given by something like code snippets, but that doesn't mean that what a concept is is "code snippet combined with other such snippets to generate predictions".
   * Like, "concepts are code snippets combined to generate predictions" is mostly technically true, but this is like how "houses are places which store plants" is true. Yes, houses can be seen as places, I guess, and they reasonably often store plants, but this is very far from an insightful specification of what a house is.
* So, I think the "generate predictions" part is bad; here's why:
   * Instead of generating predictions, it is more correct to think of concepts as helping one do various things of ultimately practical importance.
      * Many concepts are very action-facing and most concepts are somewhat action-facing. Eg we think of a door not as such and such a collection of atoms or whatever, but as a thing that one can open and close and go through to pass between rooms. A room is a thing one can be inside. To open a door is to make passage through it possible.
   * It is intermediately correct, and also insightful, to think of concepts specifically as helping one answer questions and solve problems.
   * Actually, it's hard to see concepts as doing anything by themselves — they are instead elements of a mind which has various other elements as well, together making a capable system.
      * Eg you can calculate some quantity in a newtonian mechanical picture of a situation, but the notions of newtonian mechanics alone are inert.
   * To the extent concepts are sometimes used to make predictions:
      * These predictions are usually already high-level, ie distant from raw data. Think about eg the sorts of questions we have prediction markets for, or the precession of mercury.
      * (This is related to the previous point.) I think predictions are often not graded with an information-theoretic loss, but with some other invented metric. E.g. your calculated rate of precession of mercury should be about right; you should be about right about which types of objects you will find in a room; you should draw a picture of your friend which gets certain high-level features to be close enough.
         * There is the following response: if you eg have a guess in R^2 which is close in L^2, you could put some gaussian noise on it to predict alright wrt an information-theoretic loss. I think this response isn't taking the issue seriously. The point is that there is really nothing fundamentally right about these information-theoretic losses — it comes down to what the practical thing the prediction is supposed to help you with is — and different losses just often give different behavior. But I haven't thought this through carefully.
      * These predictions are about extremely specific things. They are noticing very specific regularities. Predicting basically any pixel in any video stream will involve a huge amount of crap. In reality, we have a sense of relevance to doing practical things, a sense of interestingness, and a search for what would be neat to say.
   * This is like how while a house often stores plants, storing plants is not THE purpose of a house.
   * caveat: In human minds, there might be trackers of some low-level visual things like curves and color-blobs that are doing reconstruction to a decent extent. That said, I'd guess that actually even here visual processing is already dropping a lot of information, and we are better off thinking about what is happening as analysis that is perhaps forced by evolutionary accident into a somewhat predictive format. I haven't thought carefully about human vision but for example I think that human auditory processing just drops phase information early on.
      * If it is true that reconstruction of inputs plays an important role in human perception, perhaps it would be more appropriate to call the current version of condensation a theory of perception than to call it a theory of concepts.
* I also think the "code snippets" part is bad; here's why:
   * Granting that we are to view concepts as code snippets, I think human concepts are specific kinds of code snippets in a specific context, and almost all the interesting work in saying which kinds of code snippets in which context remains to be done.
      * I think saying "concept are code snippets" is a lot like saying "minds are programs".
   * Here is a list of some ways in which human concepts are specific kinds of code snippets in a specific context, that are imo not captured by condensation:
      * Attached to a concept, there are ways of telling that this concept would be useful in a situation (these are maybe like functions of a representation of the situation).
         * Like, when I enter a room for the first time, I can see a chair in it. There is some process in my head that pulls the chair notion into operation. I have a computable ability to recognize something as a chair.
         * When solving a physics problem where I can figure out the velocity of an object and want to know its displacement, I immediately recall the idea of integration.
         * This is a sort of encoder idea, an idea of skillfully calculating a compression/analysis for a new context on the fly, whereas condensation only has a decoder thing going on. (Ok there is the encoder specification of "just compute a low loss condensation" but this does not provide concept-specific recognizers which are probably parts human concepts have.)
      * One specific thing going on here is that a notion registers data about potential purposes of the thing (or the introduction of the notion), and when dealing with a problem things that would be useful to do are getting generated, and there is some kind of search looking for matches between these generated wishes and the purposes familiar things/notions can help with.
      * A concept can be readily combined with other concepts and potentially other mental stuff to form phrase-ideas, sentence-proposition-thoughts, stories/pictures of situations, models/frames, systems of understanding. Notions fit in a compositional language.
         * The strings in condensation do not natively support this kind of recombining? (Yes, there is a given way of combining all the strings, but like for example it wouldn't natively support taking a bear recognizer and a has-a-scarf recognizer and turning these into a bear-with-a-scarf recognizer.)
         * The models so constructed support various specific operations — for example, we find it easy to think of development in time. See Kant on the preconditions of intuition I guess.
      * Concepts support inferences.
         * E.g. probably attached to my notion of continuity, I have stored that continuity implies having the intermediate value property; I have a tentative inference from an animal being a mammal to it having four legs.
         * There are other types of associations as well, eg having one notion be a specialization of another, a thing having properties, a property having examples.
         * This system of relations to other concepts is a large part of what makes our concepts have their meanings.
      * Concepts support learning.
         * In particular, concepts are open to new inferential relationships being added, presumably with some rules governing how these are established.
      * Human notions are soft and flexible. Concepts support analogical use. Concepts support meaning change.
         * For instance, we have little difficulty thinking of Earth as a perfect sphere in one context and as an oblate spheroid in a second context and as rugged in another.
         * Having only previously heard about satellites in an astronomical context, one might still understand what is meant by a person being a satellite of another person.
         * From a primitive notion of time, one can get to the more precise notion of time in a reference frame.
      * Concepts support analogies between thoughts made of them; these are somehow made easy to find.
         * For example, the analogy ""concepts are very specific kinds of code snippets" is very much like "minds are programs"".
      * There is a system for making new concepts of old ones, eg by af-fix-at-ion and com-pound-ing.
      * Concepts support thought and action in other ways.
         * Eg attached to the expected value notion, I have a linearity of expectation trick/method.
         * Attached to my hammer notion, I have some ways to use a hammer, presumably down to motor sequence shapes.
      * There's some sort of clarification optimization problem being solved in your mind all the time that turns a conceptive soup into a clear picture, a model that hangs together.
         * An easily visible example of this is that when hearing the sentence "My field had an unusually high density of ears this year.", after a bit of processing you might see what sense of "field" and "ear" is meant (fun fact: that sense of "ear" is not derived from the more common sense — it has a distinct etymology that led to the same string: https://en.wiktionary.org/wiki/ear).
         * Another example is that you can be confused about what the first word of a sentence someone said is until you hear the rest and process it for a few seconds and then the entire sentence clicks and you understand in particular what the first word is.
         * I think a lot of this is going on when hearing ordinary text, but it's usually less visible because.
         * This optimization problem is not about predicting some raw data, but about the picture cohering.
      * There are probably natural types of concepts: thing-notions (corresponding to nouns), thing-property-notions (adjectives), action-notions (verbs), action-property-notions (adverbs), thought-relation-indicators (complementizers), and a few others, maybe with natural subtypes.
      * You can give someone a pointer to a thing in a variety of ways (eg "London is the capital of the UK" or "London is where Charles Babbage was born" etc) and then leave and have them build up that same concept with a ton of additional correct content.
      * Similarity of code snippets is not the right notion of sameness of notions. One person can be blind and another person can be deaf, and they can have very different ways of recognizing say a train station, but we still want to see them as having the same notion in a sense.
      * There are probably various reinforcement structures responsible for the hanging-together of a concept, which I mostly cannot see clearly.
      * There are probably many more things I'm forgetting and neglecting here. I present my general views on the nature of models and concepts in[ these presentation slides](https://docs.google.com/presentation/d/1P86E15RuCLCKbDmlBdD5qrQ-crCHQGSw6m_xwwv9QaY/edit?usp=sharing).
   * I think these are not some additional structures attached to human concepts, but human concepts are not themselves without supporting most of these things, and the specific structure filled in in some of these slots is what specifies a concept (in particular, the inferential relations are constitutive).
   * I guess one could hope that some of these ideas show up in the top latent, but this is like hoping they show up in kolmogorov compression.
   * This is like how while a house is kind of a place, it's really a very specific kind of structure-place-thing.


ftnote 1. I'm assuming the algorithmic version here. I think the random variable version is even more wrong.↩︎
# LessWrong comment thread (pasted by Kaarel Hänni, 2026-10-11)

Source: https://www.lesswrong.com/posts/hTPpXCuX3TvjyHBAt/jonas-hallgren-s-shortform?commentId=zH3HodivrhKjycMsa
(lesswrong.com does not resolve from the research environment; this is the text Hänni pasted into the conversation.)

The thread has three parts:
1. **Hänni's comment.** Its opening paragraph is about a "game of questions and answers" played by human epistemic communities. It also warns about capabilities. It then copies his note "beating solomonoff induction at grokking a notion" (identical to `hanni-grokking-a-notion.md`, without the messy notes).
2. **Cole Wyeth's reply** (verbatim):
   > Interesting points.
   >
   > If you penalize the complexity of my hypotheses more steeply, I can just choose a hypothesis that is a universal distribution which penalizes complexity minimally as usual. So that won't work, at least not naively. This sort of question is studied in algorithmic statistics.
3. **Hänni's answer** (verbatim):
   > I agree with your point in the canonical solomonoff sequence prediction case. I think your point is what I mean in my note by "you have pathology of not specifying even the hypothesis in the seq prediction case (like it'll be better to drop bits and take the likelihood loss)". I think this pathology is maybe not present in "function solomonoff" (I state this in the note as well but don't really explain it), though I'm very much uncertain.
   >
   > to state the hopeful "function solomonoff" story in more detail:
   > * By "function solomonoff", I mean that we have a data set of string pairs $(x,y)$, and we think of one hypothesis as being a program that takes in an $x$ and outputs a probability distribution on strings from which $y$ is sampled. Let's say that we are in the classification case so $y\in\{0,1\}$ always (we're distinguishing pictures $x$ which show dogs vs ones which don't, say).
   > * The "canonical loss" (from which one derives a posterior distribution via exponentiation) here would be the length of the program specifying the distribution plus the negative log likelihood assigned to $y$ summed over all $(x,y)$. What I'm suggesting is this loss but with a higher coefficient on the length of the program than on the likelihood terms.
   > * Suppose that the classification boundary is most simply given by what we will consider a "simple model" of complexity $100$ bits, together with "systematic human error" which changes the answer from the simple model on a $2^{-10}$ fraction of the inputs, with the set of those inputs taking $10000$ bits to specify.
   > * If we turned this into sequence prediction by interleaving like $x_1,y_1,x_2,y_2,x_3,\ldots$, then I'd agree that if we penalize hypothesis length more steeply than likelihood, then: over getting a model which does not predict the errors, we would get a universal-like hypothesis, which in particular starts to predict the human errors after being conditioned on sufficiently many bits. So the idea of more steep penalization of hypothesis length doesn't do what we want in the sequence prediction case. But I have some hope that the function case doesn't have this pathology?
   > * Some models of the given data in the function case:
   > 	* the "good model": The distribution is given by the simple model with a $p=2^{-10}$ probability of flipping the answer on top (independently on each input). This gets complexity loss like $100$ plus something small for specifying the flip model, and its expected neg log likelihood is $-p\log_2 p - (1-p)\log_2 (1-p)\approx p\log_2(1/p) \approx 1/100$.
   > 	* the "model that learns the errors": This should generically take $100+10000=10100$ bits to specify, and it gets $0$ expected neg log likelihood.
   > 	* the "50/50 random distribution" model: This takes $\approx 0$ bits to specify and has $1$ bit of expected neg log likelihood.
   > 	* some "universal hypothesis model": I'm not actually sure what this would even be in the function setting? If you handled the likelihood part by giving a global string of random bits which gets conditioned on other input-output pairs, then I agree we could write something bad just like in the sequence prediction case. But if each input gets its own private randomness, then I don't see how to write down a universal hypothesis that gets good loss here.
   > * So at least given these models, it looks like the "good model" could be a vertex of the convex hull of the set of attainable (hypothesis complexity, expected neg log likelihood) tuples? If it's on the convex hull, it's picked out by some loss of the form described (even in the limit of many data points, though we will need to increase the hypothesis term coefficient compared to the sum of log likelihoods term as the data set size increases, ie in the bayesian picture we will need to pick a stronger prior when the data set is larger in this example).
   >
   > that said:
   > * Maybe I'm just failing to construct the right "universal hypothesis" for this example?
   > * It seems plausible that some other pathology is present that prevents nice behavior.
   > 	* I haven't spent that much time trying to come up with other pathological constructions or searching for a proof that sth like the good model is optimal for some hyperparameter setting.
   > * I can see some other examples where this functional setup still doesn't work nicely. I might write more about that in a later comment. The example here is definitely somewhat cherry-picked for the idea to work, though I also don't consider it completely contrived.
   > * I think it's very unlikely this steeper penalization is anywhere close to a full solution to the philosophical problem here. I only have some hope that it works in some specific toy cases.

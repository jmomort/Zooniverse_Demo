window.app ?= {}

Api = zooniverse.Api
api = new Api project: 'planet_four'

TopBar = zooniverse.controllers.TopBar
topBar = new TopBar
topBar.el.appendTo document.body
$ = window.jQuery

Subject = zooniverse.models.Subject
Classification = zooniverse.models.Classification
User = zooniverse.models.User

class FakeSubject extends Spine.Model
  @configure "FakeSubject", "parent", "child","p_def","c_def"

  toSentence: -> [@child, "is a kind of", @parent].join(' ')


##Make some fake initial data for FakeSubjects"
fsubj=FakeSubject.fromJSON """[
                           {"parent":"abdominal disorder","child":"diabetes","p_def":"A disorder of the abdomen","c_def":"a disease that affects insulin","id":"c-0"}
                           ]"""
subj.save() for subj in fsubj
console.log JSON.stringify(FakeSubject)

class Classifier extends Spine.Controller

  onChangeAnnotate: (e) ->
    value = $(e.target).val()

    # Update the classification when the user works the controls:
    @classification.removeAnnotation @classification.annotations[0]
    @classification.annotate quality: value

  onClickNext: ->
    #@classification.send()
    console.log @classification.annotations
    console.log 'Sending classification'
    Subject.next()

  events:
    'change input[name="quality"]': 'onChangeAnnotate'
    'click button[name="next"]': 'onClickNext'

  constructor: ->
    super

    User.on 'change', (e, user) =>
      Subject.next()
    #if user?.project.tutorial_done
    #  if @classification.subject.metadata.tutorial
    # A user is logged in and they've already finished the tutorial.
    #    Subject.next()
    #else
    # Load the tutorial subject and start the tutorial!

    Subject.on 'select', =>
      @classification = new Classification subject: Subject.current
      @classification.annotate quality:"unknown"
      @render()

  render: ->
    fsubj = FakeSubject.first()
    @el.html """
             <div class="classifier">
             <div class="instructions">Using the definitions provided, determine if the following fact is correct.<br/>
            If for any reason you wish to skip, select "Unknown".
             </div>
             </br>
             <div class="def1"><i>#{fsubj.child}</i>: #{fsubj.c_def}	</div>
             </br>
             <div class="def2"><i>#{fsubj.parent}</i>: #{fsubj.p_def}	</div>
             </br>
             <div class="statement"> <h2><i>#{fsubj.child}</i> is a kind of <i>#{fsubj.parent}</i></h2>	</div>
             <div class="response">
             <input type="radio" name="quality" value="correct" id="correct" class="input-hidden" />
             <label for="correct"><button class="response_selection">Correct</button></label>
             &nbsp;
             <input type="radio" name="quality" value="incorrect" id="incorrect" class="input-hidden"/>
             <label for="incorrect"><button class="response_selection">Incorrect</button></label>
             &nbsp;
             <input type="radio" name="quality" value="unknown" id="unknown" class="input-hidden"/>
             <label for="unknown"><button class="response_selection">Unknown</button></label >
             &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
             <button name="next" class="next_button">Next</button>
             </div>
             </div>
             """

classifier = new Classifier
classifier.el.appendTo document.body


User.fetch()


window.app.main = {api, topBar, classifier}

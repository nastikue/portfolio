class MapPage
  constructor: (id)->
    @page = window.structure.pages[id]
    @firstStep = 'step1'
    @stepsStackDomElement = @page.getElementsByClassName('steps-stack')[0]
    @addButtonsEventListener(['next', 'back', 'reset'], ['goToNextStep', 'goToPreviousStep', 'goToPreviousStep'])
    @history = window.History
    @history.getAllStepsData(id)

  addButtonsEventListener: (buttons, methods)->
    buttons.forEach (button, index) =>
      buttonElement = @page.getElementsByClassName(button)[0]
      buttonElement.addEventListener 'tap', ()=>
        debugger
        @[methods[index]]()

  checkMode: ()->
    unless @page.classList.contains "steps-mode" then @page.classList.add "steps-mode"

  resetToInitial: ()->
    @history.clear()
    @changeStepTo @firstStep
    @page.classList.remove "steps-mode"

  clearStepsStackElement: ()->
    @stepsStackDomElement.classList.remove("single-step")
    @stepsStackDomElement.innerHTML = ''

  createHeader2: (text)->
    header2 = document.createElement 'h2'
    header2.innerHTML = text
    header2

  createButton: (dataAttributeValue)->
    backButton = document.createElement 'button'
    backButton.setAttribute('data-goto-step', dataAttributeValue)
    backButton.classList.add 'arrow'
    backButton.classList.add 'back'
    backButton

  createParagraph: (text)->
    paragraph = document.createElement 'p'
    paragraph.innerHTML = text
    paragraph

  createList: (list)->
    blocksList = document.createElement 'ul'
    list.forEach (item)=>
      listItem = document.createElement 'li'
      listItem.innerHTML = item
      blocksList.appendChild listItem
    blocksList

  createDiv: (blocksContent)->
    blocks = document.createElement 'div'
    if blocksContent.description
      blocks.appendChild @createParagraph(blocksContent.description)
    if blocksContent.blocks_list
      blocks.appendChild @createList(blocksContent.blocks_list)
    blocks

  createStepElement: (step, isCurrentStep = false)->
    if step.data
      stepData = step.data.introduction
      stepDiv = document.createElement 'div'
      stepDiv.appendChild @createButton(step.id)
      stepDiv.appendChild @createHeader2(stepData.caption)
      if isCurrentStep
        if stepData.text
          stepData.text.forEach (paragraph)=>
            stepDiv.appendChild @createParagraph(paragraph)
        if stepData.blocks
          stepDiv.appendChild @createDiv(stepData.blocks)
      stepDiv
    else
      null

  updateStepsStack: ()->
    @clearStepsStackElement()
    @history.steps.forEach (step)=>
      stepElement = @createStepElement step, @history.isCurrentStep(step)
      @stepsStackDomElement.appendChild stepElement
    if @history.steps.length is 1 then @stepsStackDomElement.classList.add("single-step")

  goToStep: (step)->
    if step
      @changeStepTo step
      @updateStepsStack()
      @checkMode()

  goToNextStep: ()->
    step = event.target.attributes['data-goto-step']?.value
    unless step
      buttonIndex = event.target.attributes['data-button-index']?.value
      step = @history.currentStep.next[buttonIndex]
    @history.stepNext step
    @changeStepTo step

  goToPreviousStep: ()->
    step = event.target.attributes['data-goto-step']?.value
    if !step or step is @history.steps[0].id
      @resetToInitial()
    else
      step = @history.stepBack(step).id
      @changeStepTo step

  changeStepTo: (step)->
    @page.classList.remove @page.currentStep
    @page.classList.add step
    @page.currentStep = step


mapPage = new MapPage('map')
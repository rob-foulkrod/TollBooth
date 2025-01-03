module.exports = async function (context, eventGridEvent) {
    context.log(typeof eventGridEvent);
    context.log(eventGridEvent);

    context.bindings.outputDocument = {
        fileName: eventGridEvent.data['fileName'],
        licensePlateText: '',
        timeStamp: eventGridEvent.data['timeStamp'],
        resolved: false
    };

    context.done();
};
module.exports = function (context, eventGridEvent) {
    context.log(typeof eventGridEvent);
    context.log(eventGridEvent);

    context.bindings.outputDocument = {
        fileName: eventGridEvent.data['fileName'],
        licensePlateText: eventGridEvent.data['licensePlateText'],
        timeStamp: eventGridEvent.data['timeStamp'],
        exported: false
    };

    context.done();
};
class NotImplementedException extends Lang.Exception {
    //! Constructor
    //! @param function string name of function that has not been implemented.
    function initialize() {
        Exception.initialize(function);
        self.mMessage = function + "not implemented";
    }
}

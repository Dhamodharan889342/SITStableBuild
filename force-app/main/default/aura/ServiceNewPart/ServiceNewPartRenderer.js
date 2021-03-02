/****************************************************************************************
 * @author          Lee Donghu
 * @date            2019-06-11
 *
 * @group           Service
 * @group-content   Service
 *
 * @description     ServiceNewPartRenderer.js
 ****************************************************************************************/

({
    afterRender: function (component, helper) {
        this.superAfterRender();

        /*
            We are not handling this with a controller method as that might be a performance pitfall.
            Instead we are using the mechanism described in this blog post:
            https://johnresig.com/blog/learning-from-twitter/
            This avoids loading getting called on every scroll event. One scroll with the mouse wheel can trigger quite a few
            events which will all trigger lightning. No need to say this can be a hazard for performance.
            Instead we are add a listener to the div container and are setting a variable to true; That's all the logic
            that is executed outside a lightning cycle.
            Every x miliseconds we check if a scroll was done and only then we execute our logic.
            This will make sure the scrolling remains smooth as no logic has to be executed for every scroll.

            Logic is added to the afterRender because on init the div element is not yet added to the page.
        */

        var scrolled;//Variable that will be bound to the onscroll function and interval function to check if the user has scrolled
        var div = component.find('scroll_container');
        console.log('div',div);
        if (!$A.util.isEmpty(div)) {
            div = div.getElement();
            div.onscroll = function () {
                scrolled = true;
            }

            var noScroll = false;//Determines if there is a scrollbar or not.
            console.log(noScroll);
            //Interval function to check if the user scrolled or if there is a scrollbar
            var intervalId = setInterval($A.getCallback(function () {
                if (scrolled) //The user scrolled so handle the scroll logic
                {
                    scrolled = false;
                    console.clear();

                    //helper.handleContainerScrolled(component);
                } else {
                    if (!(div.clientHeight < div.scrollHeight) && !noScroll)//There is no scrollbar and it is the first time
                    {
                        noScroll = true;
                        var sEvent = component.getEvent('scrolled');
                        sEvent.fire();
                    } else if ((div.clientHeight < div.scrollHeight))//There is a scroll bar
                    {
                        noScroll = false;
                    }
                }
            }), 750);
            component.set('v.intervalId', intervalId);
            console.log(intervalId);
        }
    },

    unrender: function (component, helper) {

        this.superUnrender();

        // Since setInterval() will be called even after component is destroyed
        // we need to remove it in the unrender
        window.clearInterval(component.get("v.intervalId"));
    }
})
SLCircleGestureRecognizer
=========================

A gesture recognizer for detecting circular gestures

## Usage

Create an instance of the gesture recognizer and add it to a view like you would with any other gesture recognizer:

```Objectivec
SLCircleGestureRecognizer *circle = [[SLCircleGestureRecognizer alloc] initWithTarget:self action:@selector(didCircleInView:)];
[someView addGestureRecognizer:circle];
```

Then wait for callbacks on the selector you initiated it with. You can get the progess of circles from the `progress` property. The progress is reported in percent (1.0 = 100%, 0.0 = 0%), and 100% is 360 degrees.

```Objectivec
- (void)didCircleInView:(SLCircleGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Progess: %d", gestureRecognizer.progess);
}
```

## Issues

At the moment this reports the progress relative to the top, not relative to where the gesture started. I'll fix that soon.
class StackException extends RuntimeException{    
  public StackException(String err) {
    super(err);
  }
}

public class Stack<T> {
  private Object[] S;
  private int top;
  private int capacity;
  
  public Stack(int size){
    capacity = size;
    S = new Object[size];
    top = -1;
  }

  public Stack(){
    this(100);
  }
  
  public T peek() {
    if(isEmpty())
      throw new StackException("stack is empty");
    return (T)S[top];
  }
  
  public T peek(int indexFromTop) {
    //Accessing negative indexes should be impossible.
    if(top-indexFromTop < 0)
      throw new StackException("stack is empty");
    return (T)S[top-indexFromTop];
  }
  
  public boolean isEmpty(){
    return top < 0;
  }
  
  public int size(){
    return top+1; 
  }
  
  public void seek(int index) {
  
  }
  
  public void empty() {
    top = -1;
  }

  public void push(T e){
    if(size() == capacity)
      throw new StackException("stack is full");
    S[++top] = e;
  }
  
  public T pop() throws StackException{
    if(isEmpty())
      throw new StackException("stack is empty");
    // this type cast is safe because we type checked the push method
    return (T) S[top--];
  }
  
  public T top() throws StackException{
    if(isEmpty())
      throw new StackException("stack is empty");
    // this type cast is safe because we type checked the push method
    return (T) S[top];
  }
}














class Click {
  private boolean dragging = false;
  private int clickDelay = 0;
  private boolean click = false;
  private boolean draggingEnd = false;
  
  public boolean isDragging() {
    return dragging;
  }
  
  public void update() {
    draggingEnd = false;
    if (!mousePressed && dragging) {
      dragging = false;
      draggingEnd = true;
    }
    if (clickDelay > 0) {
      clickDelay--;
    }
    if (!click && mousePressed) {
      click = true;
      clickDelay = 1;
    }
    if (click && !mousePressed) {
      click = false;
    }
  }
  
  public boolean draggingEnded() {
    return draggingEnd;
  }
  
  public void beginDrag() {
    if (mousePressed && clickDelay > 0) {
      dragging = true;
    }
  }
  
  public boolean clicked() {
    return (clickDelay > 0);
  }
  
  
}



class QuadVertices {
    public PVector v[] = new PVector[4];
    
    {
      v[0] = new PVector(0,0);
      v[1] = new PVector(0,0);
      v[2] = new PVector(0,0);
      v[3] = new PVector(0,0);
    }
    
    public QuadVertices() {
    
    }
    public QuadVertices(float xStart1,float yStart1,float xStart2,float yStart2,float xEnd1,float yEnd1,float xEnd2,float yEnd2) {
      v[0].set(xStart1, yStart1);
      v[1].set(xStart2, yStart2);
      v[2].set(xEnd1,   yEnd1);
      v[3].set(xEnd2,   yEnd2);
    }
}

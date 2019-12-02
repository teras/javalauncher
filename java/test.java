package test;

public class test {
    public static void main(String[] args) {
        System.out.println("Arguments " + (args == null ? "none" : ("(" + args.length + ") " + java.util.Arrays.asList(args).toString())));
        System.out.println("value1=" + System.getProperty("value1"));
        System.out.println("value2=" + System.getProperty("value2"));
        System.out.println("value3=" + System.getProperty("value3"));
        System.out.println("value4=" + System.getProperty("value4"));
        System.out.println("self.exec=" + System.getProperty("self.exec"));
    }
}

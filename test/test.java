package test;

public class test {
    public static void main(String[] args) {
        System.out.println("Arguments " + (args == null ? "none" : ("(" + args.length + ") " + java.util.Arrays.asList(args).toString())));
    }
}

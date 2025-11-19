export const authAdmin = (req, res, next) => {
    // Authentication logic for admin users
    console.log('Hi you are accessing admin route');
    next();
};
import React, { createContext, useState, useEffect } from 'react';
import { cartAPI } from '../services/api';

export const CartContext = createContext();

export const CartProvider = ({ children }) => {
    const [cart, setCart] = useState({ items: [], total: 0 });
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchCart();
    }, []);

    const fetchCart = async () => {
        try {
            setLoading(true);
            const { data } = await cartAPI.get();
            setCart(data.cart);
        } catch (error) {
            // User may not be logged in — use local cart
            console.error('Cart fetch skipped:', error?.response?.status);
        } finally {
            setLoading(false);
        }
    };

    const addToCart = async (productId, quantity = 1) => {
        try {
            const { data } = await cartAPI.add({ productId, quantity });
            setCart(data.cart);
            return { success: true };
        } catch (error) {
            return { success: false, message: error.response?.data?.message || 'Failed to add' };
        }
    };

    const removeFromCart = async (cartItemId) => {
        try {
            await cartAPI.remove(cartItemId);
            fetchCart();
        } catch (error) {
            console.error('Failed to remove item:', error);
        }
    };

    const clearCart = async () => {
        try {
            await cartAPI.clear();
            setCart({ items: [], total: 0 });
        } catch (error) {
            console.error('Failed to clear cart:', error);
        }
    };

    return (
        <CartContext.Provider value={{ cart, loading, addToCart, removeFromCart, clearCart, refreshCart: fetchCart }}>
            {children}
        </CartContext.Provider>
    );
};
